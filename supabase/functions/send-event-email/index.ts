import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY")
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")

serve(async (req) => {
  try {
    // Gestione sicura del body per prevenire errori di parsing da dispositivi mobili
    const rawBody = await req.text();
    if (!rawBody) {
      return new Response(JSON.stringify({ error: "Body della richiesta vuoto" }), {
        headers: { "Content-Type": "application/json" },
        status: 400,
      });
    }

    const data = JSON.parse(rawBody);
    const { evento_id } = data;

    if (!evento_id) {
      return new Response(JSON.stringify({ error: "evento_id mancante" }), {
        headers: { "Content-Type": "application/json" },
        status: 400,
      });
    }

    const supabase = createClient(SUPABASE_URL!, SUPABASE_SERVICE_ROLE_KEY!);

    // 1. Recupera l'evento
    const { data: evento, error: eventoError } = await supabase
      .from('eventi')
      .select('*')
      .eq('id', evento_id)
      .single();

    if (eventoError || !evento) {
      throw new Error("Evento non trovato nel database");
    }

    // 2. Recupera l'email dell'amministratore
    let emailDestinatario = "mc.applicazioni@gmail.com";
    if (evento.amministratore_id) {
      const { data: utente } = await supabase
        .from('utenti')
        .select('email')
        .eq('id', evento.amministratore_id)
        .single();

      if (utente?.email) {
        emailDestinatario = utente.email;
      }
    }

    // 3. Recupera i gruppi (Conti) e crea una mappa ID -> Nome Gruppo
    const { data: gruppi } = await supabase
      .from('gruppi')
      .select('*')
      .eq('evento_id', evento_id);

    const gruppoMap = new Map();
    if (gruppi) {
      gruppi.forEach((g: any) => {
        gruppoMap.set(g.id, g.gruppo);
      });
    }

    // 4. Recupera le spese dell'evento
    const { data: spese } = await supabase
      .from('spese')
      .select('id, evento_id, data, localita, tipologia, causale, importo')
      .eq('evento_id', evento_id);

    // 5. Recupera i giroconti dell'evento
    const { data: giroconti } = await supabase
      .from('giroconti')
      .select('*')
      .eq('evento_id', evento_id);

    const { nome, tipo_evento, data_inizio, data_fine, amministratore, valuta_target, totale_spesa, pro_capite, stato } = evento;

    // Funzioni di formattazione
    const formatMoney = (val: any) => Number(val || 0).toFixed(2);
    
    const formatConguaglioHTML = (val: any) => {
      const num = Number(val || 0);
      if (num > 0) {
        return `<span style="color: #2e7d32; font-weight: bold;">Avere ${num.toFixed(2)}</span>`;
      }
      if (num < 0) {
        return `<span style="color: #c62828; font-weight: bold;">Dare ${Math.abs(num).toFixed(2)}</span>`;
      }
      return `0.00`;
    };

    // Converte timestamp (es. 2026-09-04T00:07:25...) in GG-MM-AAAA
    const formatDate = (dateStr: string) => {
      if (!dateStr) return '-';
      try {
        const parts = dateStr.split('T')[0].split('-');
        if (parts.length === 3) {
          return `${parts[2]}-${parts[1]}-${parts[0]}`;
        }
        return dateStr;
      } catch (e) {
        return dateStr;
      }
    };

    const html = `
      <div style="font-family: Arial, sans-serif; padding: 20px; color: #333;">
        
        <h1 style="color: #111; border-bottom: 2px solid #eee; padding-bottom: 10px;">${nome ?? 'Evento'}</h1>

        <p><strong>Tipo evento:</strong> ${tipo_evento ?? '-'}</p>
        <p><strong>Periodo:</strong> ${formatDate(data_inizio)} – ${formatDate(data_fine)}</p>
        <p><strong>Amministratore:</strong> ${amministratore ?? '-'}</p>
        <p><strong>Valuta target:</strong> ${valuta_target ?? '-'}</p>
        <p><strong>Totale spesa:</strong> ${formatMoney(totale_spesa)}</p>
        <p><strong>Pro capite:</strong> ${formatMoney(pro_capite)}</p>
        <p><strong>Stato:</strong> ${stato ?? '-'}</p>

        <!-- SEZIONE TEAMS -->
        <h2 style="color: #333; margin-top: 30px;">Teams</h2>
        <table style="width: 100%; border-collapse: collapse; margin-top: 10px; font-size: 14px;">
          <thead>
            <tr style="background-color: #f8f9fa;">
              <th style="text-align: left; border-bottom: 1px solid #ccc; padding: 8px;">Team</th>
              <th style="text-align: left; border-bottom: 1px solid #ccc; padding: 8px;">Persone</th>
              <th style="text-align: left; border-bottom: 1px solid #ccc; padding: 8px;">Costo gruppo</th>
              <th style="text-align: left; border-bottom: 1px solid #ccc; padding: 8px;">Saldo</th>
              <th style="text-align: left; border-bottom: 1px solid #ccc; padding: 8px;">Conguaglio</th>
            </tr>
          </thead>
          <tbody>
            ${Array.isArray(gruppi) && gruppi.length > 0
              ? gruppi.map((g: any) => `
                <tr>
                  <td style="padding: 8px; border-bottom: 1px solid #eee;">${g.gruppo ?? '-'}</td>
                  <td style="padding: 8px; border-bottom: 1px solid #eee;">${g.numero_persone ?? 0}</td>
                  <td style="padding: 8px; border-bottom: 1px solid #eee;">${formatMoney(g.costo_gruppo)}</td>
                  <td style="padding: 8px; border-bottom: 1px solid #eee;">${formatMoney(g.saldo)}</td>
                  <td style="padding: 8px; border-bottom: 1px solid #eee;">${formatConguaglioHTML(g.conguaglio)}</td>
                </tr>
              `).join("")
              : `<tr><td colspan="5" style="padding: 8px; text-align: center; color: #777;">Nessun team trovato</td></tr>`}
          </tbody>
        </table>

        <!-- SEZIONE SPESE -->
        <h2 style="color: #333; margin-top: 30px;">Spese</h2>
        <table style="width: 100%; border-collapse: collapse; margin-top: 10px; font-size: 14px;">
          <thead>
            <tr style="background-color: #f8f9fa;">
              <th style="text-align: left; border-bottom: 1px solid #ccc; padding: 8px;">Data</th>
              <th style="text-align: left; border-bottom: 1px solid #ccc; padding: 8px;">Località</th>
              <th style="text-align: left; border-bottom: 1px solid #ccc; padding: 8px;">Tipologia</th>
              <th style="text-align: left; border-bottom: 1px solid #ccc; padding: 8px;">Causale</th>
              <th style="text-align: left; border-bottom: 1px solid #ccc; padding: 8px;">Importo</th>
            </tr>
          </thead>
          <tbody>
            ${Array.isArray(spese) && spese.length > 0
              ? spese.map((s: any) => `
                <tr>
                  <td style="padding: 8px; border-bottom: 1px solid #eee;">${formatDate(s.data)}</td>
                  <td style="padding: 8px; border-bottom: 1px solid #eee;">${s.localita ?? '-'}</td>
                  <td style="padding: 8px; border-bottom: 1px solid #eee;">${s.tipologia ?? '-'}</td>
                  <td style="padding: 8px; border-bottom: 1px solid #eee;">${s.causale ?? '-'}</td>
                  <td style="padding: 8px; border-bottom: 1px solid #eee;">${formatMoney(s.importo)}</td>
                </tr>
              `).join("")
              : `<tr><td colspan="5" style="padding: 8px; text-align: center; color: #777;">Nessuna spesa registrata</td></tr>`}
          </tbody>
        </table>

        <!-- SEZIONE GIROCONTI -->
        <h2 style="color: #333; margin-top: 30px;">Giroconti</h2>
        <table style="width: 100%; border-collapse: collapse; margin-top: 10px; font-size: 14px;">
          <thead>
            <tr style="background-color: #f8f9fa;">
              <th style="text-align: left; border-bottom: 1px solid #ccc; padding: 8px;">Data</th>
              <th style="text-align: left; border-bottom: 1px solid #ccc; padding: 8px;">Da Team</th>
              <th style="text-align: left; border-bottom: 1px solid #ccc; padding: 8px;">A Team</th>
              <th style="text-align: left; border-bottom: 1px solid #ccc; padding: 8px;">Importo</th>
            </tr>
          </thead>
          <tbody>
            ${Array.isArray(giroconti) && giroconti.length > 0
              ? giroconti.map((gc: any) => {
                const daTeam = gruppoMap.get(gc.da_gruppo_id) ?? gc.da_gruppo_id ?? '-';
                const aTeam = gruppoMap.get(gc.a_gruppo_id) ?? gc.a_gruppo_id ?? '-';
                return `
                <tr>
                  <td style="padding: 8px; border-bottom: 1px solid #eee;">${formatDate(gc.data_giroconto)}</td>
                  <td style="padding: 8px; border-bottom: 1px solid #eee;">${daTeam}</td>
                  <td style="padding: 8px; border-bottom: 1px solid #eee;">${aTeam}</td>
                  <td style="padding: 8px; border-bottom: 1px solid #eee;">${formatMoney(gc.giroconto)}</td>
                </tr>
              `;
              }).join("")
              : `<tr><td colspan="4" style="padding: 8px; text-align: center; color: #777;">Nessun giroconto registrato</td></tr>`}
          </tbody>
        </table>

        <hr style="margin-top: 40px; border: none; border-top: 1px solid #ddd;" />
        <p style="font-size: 12px; color: #999; margin-top: 20px;">
          Email generata automaticamente da <strong>Spese di Gruppo</strong>.
        </p>
      </div>
    `;

    const res = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${RESEND_API_KEY}`,
      },
      body: JSON.stringify({
        from: "noreply@mcapplicazioni.com",
        to: [emailDestinatario],
        subject: `${nome ?? 'Evento'}`,
        html: html,
      }),
    });

    const result = await res.json();

    if (!res.ok) {
      throw new Error(JSON.stringify(result));
    }

    return new Response(JSON.stringify({ success: true, result }), {
      headers: { "Content-Type": "application/json" },
      status: 200,
    });

  } catch (error: any) {
    console.error("Errore invio email:", error.message);
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { "Content-Type": "application/json" },
      status: 400,
    });
  }
});