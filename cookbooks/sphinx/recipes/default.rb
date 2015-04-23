#
# Cookbook Name:: sphinx
# Recipe:: default
#

# Set your application name here
appname = "jenkins"

# Uncomment the flavor of sphinx you want to use
flavor = "thinking_sphinx"
#flavor = "ultrasphinx"
flavor_abbr = "ts"

# If you want to install on a specific utility instance rather than
# all application instances, uncomment and set the utility instance
# name here. Note that if you use a utility instance, your very first
# deploy may fail because the initial database migration will not have
# run by the time this executes on the utility instance. If that occurs
# just deploy again and the recipe should succeed.

utility_name = nil
# utility_name = "sphinx"

# If you want to have scheduled reindexes in cron, enter the minute
# interval here. This is passed directly to cron via /, so you should
# only use numbers between 1 - 59.
#
# If you don't want scheduled reindexes, just leave this set to nil.
# Setting it equal to 10 would run the cron job every 10 minutes.

cron_interval = nil #If this is not set your data will NOT be indexed


if ! File.exists?("/data/#{appname}/current")
  Chef::Log.info "Sphinx was not configured because the app must be deployed first.  Please deploy it then re-run custom recipes."
else
  if (utility_name.present? && node[:name] == utility_name) || (utility_name.nil? && ['solo', 'app', 'app_master'].include?(node[:instance_role]))
    run_for_app(appname) do |app_name, data|
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

      directory "/data/#{app_name}/shared/config/sphinx" do
        recursive true
        owner node[:owner_name]
        group node[:owner_name]
        mode 0755
      end

      cookbook_file "/etc/logrotate.d/sphinx" do
        owner "root"
        group "root"
        mode 0755
        source "sphinx.logrotate"
        backup false
        action :create
      end
    end
  end
end
