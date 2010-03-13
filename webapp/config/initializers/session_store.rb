# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_ohm_session',
  :secret      => 'bf5f2a39a563cec172b0cdfe6cfdc76a688d1007e42ddfaa2e3a143c48505975f1ad846ab0e8edaf717203105f7112277a25359c9259fee90de894350185a5b2'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
