import { serve } from "https://deno.land"
import { createClient } from "https://esm.sh"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Manejo del preflight CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    
    // Instanciamos el cliente con privilegios administrativos para actualizar el Escrow ignorando RLS
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // Se extrae el cuerpo del evento enviado por Stripe
    const event = await req.json()

    // Gestión atómica del tipo de evento recibido
    switch (event.type) {
      case 'payment_intent.succeeded': {
        const paymentIntent = event.data.object
        const tradeOfferId = paymentIntent.metadata.tradeOfferId

        // Transicionamos el estado a retenido en custodia (held_in_escrow) de forma segura
        const { error } = await supabase
          .from('escrow_transactions')
          .update({ status: 'held_in_escrow', updated_at: new Date().toISOString() })
          .eq('trade_offer_id', tradeOfferId)

        if (error) throw error
        console.log(`[Stripe Webhook] Escrow actualizado con éxito para la oferta: ${tradeOfferId}`)
        break
      }
      
      case 'payment_intent.payment_failed': {
        const paymentIntent = event.data.object
        const tradeOfferId = paymentIntent.metadata.tradeOfferId
        
        console.log(`[Stripe Webhook] Intento de pago fallido para la oferta: ${tradeOfferId}`)
        break
      }
    }

    return new Response(JSON.stringify({ received: true }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })

  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})
