# frozen_string_literal: true

module SolidusPaypalMarketplace
  module Generators
    class InstallGenerator < Rails::Generators::Base
      class_option :auto_run_migrations, type: :boolean, default: false
      source_root File.expand_path('templates', __dir__)

      def install_solidus_paypal_commerce_platform
        run_migrations = options[:auto_run_migrations]
        run "bin/rails generate solidus_paypal_commerce_platform:install --auto-run-migrations=#{run_migrations}"
      end

      def copy_initializer
        template 'initializer.rb', 'config/initializers/solidus_paypal_marketplace.rb'
      end

      def add_javascripts
        append_file(
          'vendor/assets/javascripts/spree/frontend/all.js',
          "//= require spree/frontend/solidus_paypal_marketplace\n"
        )
        append_file(
          'vendor/assets/javascripts/spree/backend/all.js',
          "//= require spree/backend/solidus_paypal_marketplace\n"
        )
      end

      def add_stylesheets
        inject_into_file 'vendor/assets/stylesheets/spree/frontend/all.css', " *= require spree/frontend/solidus_paypal_marketplace\n", before: %r{\*/}, verbose: true # rubocop:disable Layout/LineLength
        inject_into_file 'vendor/assets/stylesheets/spree/backend/all.css', " *= require spree/backend/solidus_paypal_marketplace\n", before: %r{\*/}, verbose: true # rubocop:disable Layout/LineLength
      end

      def add_migrations
        run 'bin/rails railties:install:migrations FROM=solidus_paypal_marketplace'
      end

      def run_migrations
        run_migrations = options[:auto_run_migrations]
        run_migrations ||= ['', 'y', 'Y'].include?(ask('Would you like to run the migrations now? [Y/n]'))
        if run_migrations
          run 'bin/rails db:migrate'
        else
          puts 'Skipping bin/rails db:migrate, don\'t forget to run it!' # rubocop:disable Rails/Output
        end
      end
    end
  end
end
