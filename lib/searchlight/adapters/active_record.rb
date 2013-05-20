module Searchlight
  module Adapters
    module ActiveRecord

      def search_on(target)
        super
        extend Search       if is_active_record?(target)
        convert_to_relation if is_active_record_class?(target)
      end

      module Search
        def searches(*attribute_names)
          super

          # Ensure this class only adds one search module to the ancestors chain
          if @ar_searches_module.nil?
            @ar_searches_module = Named::Module.new("SearchlightActiveRecordSearches(#{self})")
            include @ar_searches_module
          end

          eval_string = attribute_names.map { |attribute_name|
            <<-UNICORN_BILE
            def search_#{attribute_name}
              search.where('#{attribute_name}' => public_send("#{attribute_name}"))
            end
            UNICORN_BILE
          }.join

          @ar_searches_module.module_eval(eval_string, __FILE__, __LINE__)
        end
      end

      protected

      def is_active_record?(target)
         is_active_record_class?(target) || is_active_record_relation?(target)
      end

      def is_active_record_class?(target)
        target.is_a?(Class) && target.ancestors.include?(::ActiveRecord::Base)
      end

      def is_active_record_relation?(target)
        target.is_a?(::ActiveRecord::Relation)
      end

      # Ensure that searches without options still return enumerable results
      def convert_to_relation
        self.search_target = (active_record_version >= 4) ? search_target.all : search_target.scoped
      end

      def active_record_version
        ::ActiveRecord::VERSION::MAJOR.to_i
      end

    end
  end
end

Searchlight::Search.extend(Searchlight::Adapters::ActiveRecord)
