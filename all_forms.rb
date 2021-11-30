require 'csv'
require 'rest-client'
require 'jwt'
require_relative 'skylark_service'
require_relative 'tools'

class MappingCsv < Tools
  def self.csv
    CSV.open('./ceshi/all_forms.csv', 'w') do |writer|
      writer << table_header
      all_forms_responses.each do |response_fields|
        response_fields['fields'].each do |response_field|
          if response_field['title'] != '-'
            writer << [response_fields['title'], '表单', response_fields['id'], response_field['title'], response_field['identity_key'], is_required?(response_field['validations'][0]), '发起表单']
          end
        end
      end
    end
  end
end

MappingCsv.csv