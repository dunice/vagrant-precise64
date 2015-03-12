node.default['php']['ext_conf_dir'] = '/etc/php5/apache2/conf.d'
node.default['mysql']['bind_address'] = '0.0.0.0'
node.default['mysql']['allow_remote_root'] = true
node.default['mysql']['server_root_password'] = 'root'

node.default['postgresql']['config']['port'] = 5432
node.default['postgresql']['password']['postgres'] = 'postgres'
node.default['postgresql']['config']['ssl'] = false
node.default['postgresql']['config']['listen_addresses'] = '*'
node.default['postgresql']['pg_hba'] = [
  {
    :type => 'local',
    :db => 'all',
    :user => 'postgres',
    :addr => nil,
    :method => 'ident'
  },
  {
    :type => 'local',
    :db => 'all',
    :user => 'all',
    :addr => nil,
    :method => 'ident'
  },
  {
    :type => 'host',
    :db => 'all',
    :user => 'all',
    :addr => '127.0.0.1/32',
    :method => 'md5'
  },
  {
    :type => 'host',
    :db => 'all',
    :user => 'all',
    :addr => '::1/128',
    :method => 'md5'
  },
  {
    :type => 'host',
    :db => 'all',
    :user => 'all',
    :addr => '0.0.0.0/0',
    :method => 'md5'
  }
]

include_recipe "apt"

execute "/usr/bin/apt-get update"
package "python-software-properties"
execute "add-apt-repository ppa:zanfur/php5.5"
execute "add-apt-repository ppa:builds/sphinxsearch-daily"
execute "/usr/bin/apt-get update"

execute "curl -sL https://deb.nodesource.com/setup | sudo bash -"

include_recipe "php"
include_recipe "apache2"
include_recipe "apache2::mod_rewrite"
include_recipe "apache2::mod_ssl"
include_recipe "apache2::mod_headers"
include_recipe "apache2::mod_expires"
include_recipe "apache2::mod_php5"
include_recipe "apache2::mod_deflate"
include_recipe "apache2::mod_filter"
include_recipe "composer"
include_recipe "postgresql::server"
include_recipe "mysql::server"

execute '/bin/mkdir -p /etc/php5/conf.d'

package "build-essential"
package "git-core"
package "make"
package "vim"
package "wget"
package "traceroute"
package "whois"
package "curl"
package "php-pear" do
    action :upgrade
end
package "nodejs"
package "php5-cli"
package "php5-fpm"
package "php5-cgi"
package "php5-dev"
package "php5-curl"
package "php5-gd"
package "php5-intl"
package "php5-mcrypt"
package "php5-pgsql"
package "php5-sqlite"
package "php5-mysql"
package "php5-tidy"
package "php5-xmlrpc"
package "php5-xsl"
package "libpcre3-dev"
package "redis-server"
package "sphinxsearch"

include_recipe "phpunit"

php_pear "xdebug" do
  action :install
end

execute "/bin/rm /etc/apache2/sites-enabled/* -Rf"
execute "/bin/rm /etc/apache2/sites-available/* -Rf"

node[:app][:web_apps].each do |identifier, app|
  web_app identifier do
    server_name app[:server_name]
    server_aliases app[:server_aliases]
    docroot app[:guest_docroot]
    php_timezone app[:php_timezone]
  end
end

template "#{node['php']['ext_conf_dir']}/xdebug.ini" do
  source "xdebug.ini.erb"
  owner "root"
  group "root"
  mode "0644"
end
