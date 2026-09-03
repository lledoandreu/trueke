import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers":
        "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Content-Type": "application/json",
};

const MAX_MESSAGES = 20;
const MAX_MESSAGE_LENGTH = 4_000;
const MAX_TOTAL_LENGTH = 12_000;
const OPENAI_TIMEOUT_MS = 30_000;

const systemInstructions =
    "Eres Trueki, el asistente inteligente de Trueke. " +
    "Ayudas a negociar de forma justa, valorar productos y sugerir " +
    "intercambios razonables. Responde de forma amable, concisa y clara.";

type ChatRole = "user" | "assistant";

type IncomingMessage = {
    role: ChatRole;
    content: string;
};

function jsonResponse(
    body: Record<string, unknown>,
    status = 200,
): Response {
    return new Response(JSON.stringify(body), {
        status,
        headers: corsHeaders,
    });
}

function getBearerToken(request: Request): string | null {
    const header = request.headers.get("Authorization");

    if (!header) {
        return null;
    }

    const match = header.match(/^Bearer\s+(.+)$/i);
    return match?.[1] ?? null;
}

function isIncomingMessage(value: unknown): value is IncomingMessage {
    if (typeof value !== "object" || value === null) {
        return false;
    }

    const message = value as Record<string, unknown>;

    return (
        (message.role === "user" || message.role === "assistant") &&
        typeof message.content === "string" &&
        message.content.trim().length > 0 &&
        message.content.length <= MAX_MESSAGE_LENGTH
    );
}

function parseMessages(value: unknown): IncomingMessage[] | null {
    if (!Array.isArray(value) || value.length === 0) {
        return null;
    }

    if (value.length > MAX_MESSAGES || !value.every(isIncomingMessage)) {
        return null;
    }

    const messages = value.map((message) => ({
        role: message.role,
        content: message.content.trim(),
    }));

    if (messages.at(-1)?.role !== "user") {
        return null;
    }

    const totalLength = messages.reduce(
        (total, message) => total + message.content.length,
        0,
    );

    if (totalLength > MAX_TOTAL_LENGTH) {
        return null;
    }

    return messages;
}

Deno.serve(async (request: Request): Promise<Response> => {
    if (request.method === "OPTIONS") {
        return new Response("ok", { headers: corsHeaders });
    }

    if (request.method !== "POST") {
        return jsonResponse({ error: "Metodo no permitido." }, 405);
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseKey =
        Deno.env.get("SUPABASE_ANON_KEY") ??
        Deno.env.get("SUPABASE_PUBLISHABLE_KEY");
    const openAiApiKey = Deno.env.get("OPENAI_API_KEY");

    if (!supabaseUrl || !supabaseKey || !openAiApiKey) {
        return jsonResponse(
            { error: "El servicio de asistente no esta disponible." },
            503,
        );
    }

    const token = getBearerToken(request);

    if (!token) {
        return jsonResponse({ error: "Autenticacion requerida." }, 401);
    }

    try {
        const supabase = createClient(supabaseUrl, supabaseKey, {
            global: {
                headers: {
                    Authorization: `Bearer ${token}`,
                },
            },
            auth: {
                persistSession: false,
                autoRefreshToken: false,
            },
        });

        const {
            data: { user },
            error: userError,
        } = await supabase.auth.getUser(token);

        if (userError || !user) {
            return jsonResponse({ error: "Autenticacion no valida." }, 401);
        }

        let body: unknown;

        try {
            body = await request.json();
        } catch {
            return jsonResponse({ error: "Solicitud no valida." }, 400);
        }

        if (typeof body !== "object" || body === null) {
            return jsonResponse({ error: "Solicitud no valida." }, 400);
        }

        const requestBody = body as Record<string, unknown>;
        const messages = parseMessages(requestBody.messages);

        if (!messages) {
            return jsonResponse(
                { error: "El historial de mensajes no es valido." },
                400,
            );
        }

        const openAiResponse = await fetch(
            "https://api.openai.com/v1/chat/completions",
            {
                method: "POST",
                headers: {
                    Authorization: `Bearer ${openAiApiKey}`,
                    "Content-Type": "application/json",
                },
                signal: AbortSignal.timeout(OPENAI_TIMEOUT_MS),
                body: JSON.stringify({
                    model: Deno.env.get("OPENAI_MODEL") ?? "gpt-4o-mini",
                    messages: [
                        { role: "system", content: systemInstructions },
                        ...messages,
                    ],
                    temperature: 0.7,
                    max_tokens: 600,
                }),
            },
        );

        if (!openAiResponse.ok) {
            return jsonResponse(
                { error: "No se pudo procesar la respuesta del asistente." },
                502,
            );
        }

        const openAiData: unknown = await openAiResponse.json();

        if (typeof openAiData !== "object" || openAiData === null) {
            return jsonResponse(
                { error: "Respuesta invalida del asistente." },
                502,
            );
        }

        const choices = (openAiData as { choices?: unknown }).choices;

        if (!Array.isArray(choices) || choices.length === 0) {
            return jsonResponse(
                { error: "El asistente no devolvio contenido." },
                502,
            );
        }

        const firstChoice = choices[0];

        const assistantMessage =
            typeof firstChoice === "object" && firstChoice !== null
                ? (firstChoice as { message?: { content?: unknown } }).message
                    ?.content
                : null;

        if (typeof assistantMessage !== "string" || !assistantMessage.trim()) {
            return jsonResponse(
                { error: "El asistente no devolvio contenido." },
                502,
            );
        }

        return jsonResponse({
            message: assistantMessage.trim(),
        });
    } catch {
        return jsonResponse(
            { error: "No se pudo procesar la solicitud." },
            500,
        );
    }
});