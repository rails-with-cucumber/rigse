set :user, "deploy"
set :domain, "itsi.portal.concord.org"
set :deploy_to, "/web/portal"
server domain, :app, :web
role :db, domain, :primary => true
