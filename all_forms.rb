require 'csv'
require 'rest-client'
require 'jwt'
require 'logger'
require_relative 'skylark_service'
require_relative 'tools'
include Tools

class MappingCsv
  def csv
    CSV.open('./ceshi/all_forms.csv', 'w') do |writer|
      first = 1
      writer << table_header
      20.times do
        write_csv(get_forms_responses(first += 50), writer)
      end
    end
  end

  private

  def write_csv(all_forms_fields, writer)
    all_forms_fields.each do |response_fields|
      response_fields['fields'].each do |response_field|
        if response_field['title'] != '-'
          writer << [response_fields['title'], '表单', response_fields['id'], response_field['title'], response_field['identity_key'], is_required?(response_field['validations'][0]), '发起表单']
        end
      end
    end
  end
end

MappingCsv.new.csv