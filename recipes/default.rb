#
# Cookbook Name:: opsworks_precompile_assets
# Recipe:: default
#
# Copyright (C) 2014 kjoyner
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
node['deploy'].each do |app_name, deploy_config|

	# TODO: We could make deploys much faster in cases where the assets don't change by
	# TODO: running a diff between last version deployed and this version deployed and
	# TODO: checking if any files changed in the app/assets directory. If nothing has
	# TODO: changed, then no need to run the precompile steps (should still provide
	# TODO: a way to override when something else like config changes require assets
	# TODO: to be recompiled.)

	rails_env = deploy_config[:rails_env]
	Chef::Log.info("Precompiling Rails assets with environment #{rails_env}")

	app_dir               = "#{deploy_config['deploy_to']}/current"
	app_shared_dir        = "#{deploy_config['deploy_to']}/shared"
	app_shared_assets_dir = "#{app_shared_dir}/assets"

	# make sure the app shared assets directory exists
	directory app_shared_assets_dir do
		owner deploy_config[:user]
		group deploy_config[:group]
		mode 0770
		action :create
		recursive true
	end

	# create a link to the shared assets directory
	link "#{app_dir}/public/assets" do
		to app_shared_assets_dir
		owner deploy_config[:user]
		group deploy_config[:group]
	end

	execute 'rake assets:precompile' do
		cwd app_dir
		user deploy_config[:user]
		command 'bundle exec rake assets:precompile'
		environment 'RAILS_ENV' => rails_env
	end

end
