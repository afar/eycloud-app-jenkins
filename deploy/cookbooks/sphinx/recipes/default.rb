#
# Cookbook Name:: sphinx
# Recipe:: default
#

# Set your application name here
appname = "afar"

# Uncomment the flavor of sphinx you want to use
flavor = "thinking_sphinx"
# flavor = "ultrasphinx"

# If you want to have scheduled reindexes in cron, enter the minute
# interval here. This is passed directly to cron via /, so you should
# only use numbers between 1 - 59.
#
# If you don't want scheduled reindexes, just leave this commented.
#
# Uncommenting this line as-is will reindex once every 10 minutes.
cron_interval = 10

if ['solo', 'util'].include?(node[:instance_role])

  # install sphinx 2.0.4
  unless `searchd --version`.include?('2.0.4')
    src_dir = "/usr/local/src"

    directory src_dir do
      owner "root"
      group "root"
      mode 0755
    end

    remote_file "#{src_dir}/sphinx-2.0.4.tar.gz" do
      source "http://sphinxsearch.com/files/sphinx-2.0.4-release.tar.gz"
      owner "root"
      group "root"
    end

    bash "unpack and install sphinx" do
      user "root"
      cwd src_dir
      code <<-EOCODE
        tar -xzf sphinx-2.0.4.tar.gz
        cd sphinx-2.0.4-release
        ./configure && make && make install
      EOCODE
    end
  end

  # be sure to replace "app_name" with the name of your application.
  run_for_app(appname) do |app_name, data|
  # node[:applications].each do |app_name, data|
    if app_name == 'afar'
      ey_cloud_report "Sphinx" do
        message "configuring #{flavor}"
      end

      directory "/data/#{app_name}/shared/sphinx" do
        owner node[:owner_name]
        group node[:owner_name]
        mode 0755
      end

      directory "/var/run/sphinx" do
        owner node[:owner_name]
        group node[:owner_name]
        mode 0755
      end

      directory "/var/log/engineyard/sphinx/#{app_name}" do
        recursive true
        owner node[:owner_name]
        group node[:owner_name]
        mode 0755
      end
    
      directory "/data/sphinx/#{app_name}" do
        recursive true
        owner node[:owner_name]
        group node[:owner_name]
        mode 0755
      end

      remote_file "/etc/logrotate.d/sphinx" do
        owner "root"
        group "root"
        mode 0755
        source "sphinx.logrotate"
        backup false
        action :create
      end

      template "/etc/monit.d/sphinx.#{app_name}.monitrc" do
        source "sphinx.monitrc.erb"
        owner 'root'
        group 'root'
        mode 0644
        variables({
                    :app_name => app_name,
                    :user => node[:owner_name],
                    :flavor => flavor,
                    :env => node[:environment][:framework_env]
        })
      end

      template "/data/#{app_name}/shared/config/#{node[:environment][:framework_env]}.sphinx.conf" do
        source "base.sphinx.conf.erb"
        owner node[:owner_name]
        group node[:owner_name]
        mode 0644
        variables({
                    :index_path => "/data/sphinx/#{app_name}",
                    :log_path => "/var/log/engineyard/sphinx/#{app_name}",
                    :app_name => app_name,
                    :user => node[:owner_name],
                    :env => node[:environment][:framework_env],
                    :db_host => node[:db_host],
                    :db_name => node[:engineyard][:environment][:apps].select{|v| v[:name] == app_name}.first['database_name'],
                    :db_user => node[:owner_name],
                    :db_pwd => node[:owner_pass],
                    :flavor => flavor
        })
      end

      # rake tasks should not be part of chef recipes - rake does not run yet since dependent on other recipes
      # ey_cloud_report "reindexing #{flavor}" do
      #   message "indexing #{flavor}"
      # end
      #
      # execute "#{flavor} reindex" do
      #   command "rake #{flavor}:reindex"
      #   user node[:owner_name]
      #   environment({
      #                 'HOME' => "/home/#{node[:owner_name]}",
      #                 'RAILS_ENV' => node[:environment][:framework_env]
      #   })
      #   cwd "/data/#{app_name}/current"
      # end

      execute "monit quit"

    end # end of app_name if
  end # end of run_for_app

end# end of if statement -- only run on main app server

if ['solo', 'app_master', 'app_slave', 'util'].include?(node[:instance_role])
  # run_for_app(appname) do |app_name, data|
  node[:applications].each do |app_name, data|
    
    
    
    template "/data/#{app_name}/shared/config/sphinx.yml" do
      owner node[:owner_name]
      group node[:owner_name]
      mode 0644
      source "sphinx.yml.erb"

      host_ip = if node[:engineyard] && node[:instance_role] != 'solo'
                  node[:engineyard][:environment][:instances].select{ |i| i['role'] == 'util' }.first['public_hostname']
                else
                  'localhost'
                end

      variables({
                  :host_ip => host_ip,
                  :log_path => "/var/log/engineyard/sphinx/#{app_name}",
                  :app_name => app_name,
                  :env => node[:environment][:framework_env]
      })
    end

  end # run on all servers
end
