import 'package:supabase_flutter/supabase_flutter.dart';

class ReportService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> generaHtmlEvento(int eventoId) async {
    // 1️⃣ EVENTO (tabella: utenti)
    final evento = await _supabase
        .from('utenti')
        .select()
        .eq('id', eventoId)
        .single();

    final eventoNome = evento['nome'] ?? '';
    final dataInizio = evento['data_inizio'] ?? '';
    final dataFine = evento['data_fine'] ?? '';
    final numeroPersone = evento['numero_persone']?.toString() ?? '';
    final localita = evento['localita'] ?? '';
    final valutaTarghet = evento['valuta_targhet'] ?? '';
    final totaleSpesa = evento['totale_spesa']?.toString() ?? '';
    final proCapite = evento['pro_capite']?.toString() ?? '';
    final amministratore = evento['amministratore'] ?? '';
    final stato = evento['stato'] ?? '';

    // 2️⃣ TEAM (gruppi) + PERSONE (persone)
    final gruppi = await _supabase
        .from('gruppi')
        .select()
        .eq('evento_id', eventoId);

    // Precarichiamo anche le persone
    final personeRows = await _supabase
        .from('persone')
        .select()
        .eq('evento_id', eventoId);

    // Mappa: gruppo_id -> lista persone
    final Map<int, List<String>> personePerGruppo = {};
    for (final p in personeRows) {
      final gid = p['grupo_id'] as int;
      final nomePersona = (p['persona'] ?? '').toString();
      personePerGruppo.putIfAbsent(gid, () => []);
      personePerGruppo[gid]!.add(nomePersona);
    }

    final StringBuffer teamsHtml = StringBuffer();
    for (final g in gruppi) {
      final int gruppoId = g['id'] as int;
      final gruppoNome = g['gruppo'] ?? '';
      final costoGruppo = g['costo gruppo']?.toString() ?? '0.00';
      final giroconti = g['giroconti']?.toString() ?? '0.00';
      final saldo = (g['saldo'] ?? 0).toDouble();
      final conguaglio = g['conguaglio']?.toString() ?? '';

      // Persone del team
      final persone = personePerGruppo[gruppoId] ?? [];
      final listaPersone = persone.isEmpty ? '-' : persone.join(', ');

      // Saldo formattato (Dare/Avere/0.00)
      String saldoFormattato;
      if (saldo < 0) {
        saldoFormattato = 'Dare ${saldo.abs().toStringAsFixed(2)}';
      } else if (saldo > 0) {
        saldoFormattato = 'Avere ${saldo.toStringAsFixed(2)}';
      } else {
        saldoFormattato = '0.00';
      }

      teamsHtml.writeln('''
      <div class="team">
        <div class="team-name">Team: $gruppoNome</div>
        <p class="small">
          Persone: $listaPersone
        </p>
        <table>
          <tr><th>Spesa totale</th><td>$costoGruppo</td></tr>
          <tr><th>Giroconti</th><td>$giroconti</td></tr>
          <tr><th>Saldo</th><td>$saldoFormattato</td></tr>
          <tr><th>Conguaglio</th><td>$conguaglio</td></tr>
        </table>
      </div>
      ''');
    }

    // 3️⃣ SPESE (spese) – ordine: data, importo, località, tipologia, causale, team
    final speseRows = await _supabase
        .from('spese')
        .select()
        .eq('evento_id', eventoId)
        .order('data', ascending: true);

    // Mappa gruppi per nome team
    final Map<int, String> nomeGruppoById = {
      for (final g in gruppi) (g['id'] as int): (g['gruppo'] ?? '').toString(),
    };

    final StringBuffer speseHtml = StringBuffer();
    for (final s in speseRows) {
      final data = s['data'] ?? '';
      final importo = s['importo']?.toString() ?? '0.00';
      final loc = s['località'] ?? '';
      final tipologia = s['tipologia'] ?? '';
      final causale = s['causale'] ?? '';
      final gruppoId = s['gruppo_id'] as int?;
      final teamNome =
          gruppoId != null ? (nomeGruppoById[gruppoId] ?? '') : '';

      speseHtml.writeln('''
        <tr>
          <td>$data</td>
          <td>$importo</td>
          <td>$loc</td>
          <td>$tipologia</td>
          <td>$causale</td>
          <td>$teamNome</td>
        </tr>
      ''');
    }

    // 4️⃣ GIROCONTI (giroconti)
    final girocontiRows = await _supabase
        .from('giroconti')
        .select()
        .eq('evento_id', eventoId);

    final StringBuffer girocontiHtml = StringBuffer();
    for (final g in girocontiRows) {
      final dataGiro = g['data_giroconto'] ?? '';
      final daId = g['da_gruppo_id'] as int?;
      final aId = g['a_gruppo_id'] as int?;
      final importo = g['importo']?.toString() ?? '0.00';

      final daTeam = daId != null ? (nomeGruppoById[daId] ?? '') : '';
      final aTeam = aId != null ? (nomeGruppoById[aId] ?? '') : '';

      girocontiHtml.writeln('''
        <tr>
          <td>$dataGiro</td>
          <td>$daTeam</td>
          <td>$aTeam</td>
          <td>$importo</td>
        </tr>
      ''');
    }

    // 5️⃣ HTML FINALE
    final html = '''
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8" />
  <title>Riepilogo evento</title>
  <style>
    body { font-family: Arial, sans-serif; font-size: 14px; color: #222; }
    h1, h2 { color: #004080; }
    table { width: 100%; border-collapse: collapse; margin-bottom: 20px; }
    th, td { border: 1px solid #ccc; padding: 6px 8px; text-align: left; }
    th { background-color: #f0f4ff; }
    .section { margin-bottom: 30px; }
    .team-name { font-weight: bold; margin-top: 10px; }
    .small { font-size: 12px; color: #666; }
  </style>
</head>
<body>

  <!-- SESSIONE 1: RIEPILOGO EVENTO -->
  <div class="section">
    <h1>Riepilogo evento</h1>
    <table>
      <tr><th>Evento</th><td>$eventoNome</td></tr>
      <tr><th>Periodo</th><td>$dataInizio – $dataFine</td></tr>
      <tr><th>Partecipanti</th><td>$numeroPersone</td></tr>
      <tr><th>Località</th><td>$localita</td></tr>
      <tr><th>Valuta</th><td>$valutaTarghet</td></tr>
      <tr><th>Totale spesa</th><td>$totaleSpesa</td></tr>
      <tr><th>Pro capite</th><td>$proCapite</td></tr>
      <tr><th>Amministratore</th><td>$amministratore</td></tr>
      <tr><th>Stato</th><td>$stato</td></tr>
    </table>
  </div>

  <!-- SESSIONE 2: TEAM + PERSONE + SALDI -->
  <div class="section">
    <h2>Team e riepilogo saldi</h2>
    $teamsHtml
  </div>

  <!-- SESSIONE 3: LISTA DELLE SPESE -->
  <div class="section">
    <h2>Lista delle spese</h2>
    <table>
      <thead>
        <tr>
          <th>Data</th>
          <th>Importo</th>
          <th>Località</th>
          <th>Tipologia</th>
          <th>Causale</th>
          <th>Team</th>
        </tr>
      </thead>
      <tbody>
        $speseHtml
      </tbody>
    </table>
  </div>

  <!-- SESSIONE 4: GIROCONTI -->
  <div class="section">
    <h2>Giroconti tra team</h2>
    <table>
      <thead>
        <tr>
          <th>Data</th>
          <th>Da team</th>
          <th>A team</th>
          <th>Importo</th>
        </tr>
      </thead>
      <tbody>
        $girocontiHtml
      </tbody>
    </table>
  </div>

</body>
</html>
''';

    return html;
  }
}
