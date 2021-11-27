class MappingCsv
  require 'csv'
  require 'rest-client'
  require 'jwt'
  require_relative 'skylark_service'

  def self.csv
    CSV.open('./ceshi/form.csv', 'w') do |writer|
      writer << ["表单名称", "类型", "表单id", "字段名称", "字段映射名", "是否必填", "字段位置"]
      [105,108].each do |form_id|
        response_fields = JSON.parse(skylark_service.query_form(form_id))
        writer << [response_fields['title'], "表单", response_fields['id'], '', '', '']
        response_fields['fields'].each do |response_field|
          if response_field['title'] != '-'
            writer << [response_fields['title'], "表单", response_fields['id'], response_field['title'], response_field['identity_key'], is_required?(response_field['validations'][0]), "发起表单"]
          end
        end
      end
    end
  end

  def self.skylark_service
    @skylark_service ||= SkylarkService.new
  end

  def self.is_required?(presence)
    if presence = 'presence'
      '是'
    else
      '否'
    end
  end

  def self.get_all_form_ids
    form_ids = []
    for i in 1..2000
      begin
        get_response = JSON.parse(skylark_service.query_form(i))
        unless get_response['title'] == '表单' || get_response['title'] == '测试'
          form_ids << i
        end
      rescue
        next
      end
    end
    form_ids
  end
end

MappingCsv.csv