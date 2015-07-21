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

	rails_env = deploy_config[:rails_env]
	Chef::Log.info("Precompiling Rails assets with environment #{rails_env}")

	app_dir    = "#{deploy_config['deploy_to']}/current"
	assets_dir = "#{app_dir}/public/assets"

	# make sure the assets directory exists
	directory assets_dir do
		owner deploy_config[:user]
		group deploy_config[:group]
		mode 0770
		action :create
		recursive true
  end

  # make sure we are using the latest version of npm
  execute 'npm update' do
    command 'npm update -g update'
  end

  # install node-packages
  #
  execute 'npm install' do
    cwd app_dir
    user deploy_config[:user]
    command 'npm install'
    environment( {'NODE_ENV' => rails_env, 'HOME' => '/home/deploy' } )
  end

  # install node-packages
  #
  execute 'npm install' do
    cwd app_dir
    user deploy_config[:user]
    command 'npm install'
    environment( {'NODE_ENV' => rails_env, 'HOME' => '/home/deploy' } )
  end

  # install typescript definition files
  execute 'tsd install' do
    cwd app_dir
    user deploy_config[:user]
    command 'node_modules/tsd/build/cli.js install'
    environment 'HOME' => '/home/deploy'
  end


  # install bower-packages
  #
  if (rails_env == 'production' || rails_env == 'staging')
    bower_install_flags = '-p'
  end
  execute 'bower install' do
    cwd app_dir
    user deploy_config[:user]
    command "node_modules/bower/bin/bower install #{bower_install_flags}"
    environment 'HOME' => '/home/deploy'
  end

  # build assets outside rails asset pipeline
  #
  if (rails_env == 'production' || rails_env == 'staging')
    gulp_build_target = 'build:production'
  else
    gulp_build_target = 'build:development'
  end
  execute 'gulp build:production' do
    cwd app_dir
    user deploy_config[:user]
    command "node_modules/gulp/bin/gulp.js #{gulp_build_target}"
    environment 'HOME' => '/home/deploy'
  end

  # build assets inside rails asset pipeline
  #
	execute 'rake assets:precompile' do
		cwd app_dir
		user deploy_config[:user]
		command 'bundle exec rake assets:precompile'
		environment 'RAILS_ENV' => rails_env
	end

end
