on('issues.labeled')
  .filter(context => context.payload.label.name === 'zatwierdzone')
  .close();

on('issues.labeled')
  .filter(context => context.payload.label.name === 'odrzucone')
  .close();

on('issues.opened', 'issues.edited')
  .filter(context => context.payload.issue.body.match(/- \[[xX]] Błąd/))
  .label('błąd');

on('issues.opened', 'issues.edited')
  .filter(context => context.payload.issue.body.match(/- \[[ ]] Błąd/))
  .unlabel('błąd');

on('issues.opened', 'issues.edited')
  .filter(context => context.payload.issue.body.match(/- \[[xX]] Komunikat dot. ciasteczek\/polityki prywatności\/RODO/))
  .label('ciasteczka/RODO');

on('issues.opened', 'issues.edited')
  .filter(context => context.payload.issue.body.match(/- \[[ ]] Komunikat dot. ciasteczek\/polityki prywatności\/RODO/))
  .unlabel('ciasteczka/RODO');

on('issues.opened', 'issues.edited')
  .filter(context => context.payload.issue.body.match(/- \[[xX]] Element społecznościowy/))
  .label('social');

on('issues.opened', 'issues.edited')
  .filter(context => context.payload.issue.body.match(/- \[[ ]] Element społecznościowy/))
  .unlabel('social');

on('issues.opened', 'issues.edited')
  .filter(context => context.payload.issue.body.match(/- \[[xX]] Wyskakujące okienko/))
  .label('popup');

on('issues.opened', 'issues.edited')
  .filter(context => context.payload.issue.body.match(/- \[[ ]] Wyskakujące okienko/))
  .unlabel('popup');

on('issues.opened', 'issues.edited')
  .filter(context => context.payload.issue.body.match(/- \[[xX]] Pytanie/))
  .label('pytanie');

on('issues.opened', 'issues.edited')
  .filter(context => context.payload.issue.body.match(/- \[[ ]] Pytanie/))
  .unlabel('pytanie');

on('issues.opened', 'issues.edited')
  .filter(context => context.payload.issue.body.match(/- \[[xX]] Ulepszenie/))
  .label('ulepszenie');

on('issues.opened', 'issues.edited')
  .filter(context => context.payload.issue.body.match(/- \[[ ]] Ulepszenie/))
  .unlabel('ulepszenie');

on('issues.opened', 'issues.edited')
  .filter(context => context.payload.issue.body.match(/- \[[xX]] Redundancja/))
  .label('redundancja');

on('issues.opened', 'issues.edited')
  .filter(context => context.payload.issue.body.match(/- \[[ ]] Redundancja/))
  .unlabel('redundancja');
