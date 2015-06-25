require 'rest-more'

APP_KEY = 'lm2tsx9zo841kzt'
APP_SECRET = 'fr6q2orocucy6jn'

TOKEN = 's9xzt1k2s4rpl9do'
SECRET = 'lkm9y8wdv62xir8'

Dropbox = RC::Dropbox.new(
  :root => 'auto',
  :consumer_key => APP_KEY,
  :consumer_secret => APP_SECRET,
  :oauth_token => TOKEN,
  :oauth_token_secret => SECRET,
  :log_method => method(:puts)
)
