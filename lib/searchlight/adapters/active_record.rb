module Searchlight
  module Adapters
    module ActiveRecord

      def search_on(target)
        super
        if target.is_a?(Class) && target.ancestors.include?(::ActiveRecord::Base) ||
          target.is_a?(::ActiveRecord::Relation)
          extend Search
        end
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

    end
  end
end

Searchlight::Search.extend(Searchlight::Adapters::ActiveRecord)
