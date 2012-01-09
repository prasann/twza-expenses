module ExcelDataExporter
  TIME_FORMAT = "%m-%d-%Y"
  TYPE_HEADER = "application/excel; charset=UTF-8; header-present"
  FILE_EXTENSION = ".xls"

  @data_to_export = []
  @file_headers = []
  @model = nil
  @file_name = nil
  @serial_number_column_needed = false

 private
 def stream_data(declared_fields)
    row = []
    row_count = 1
    csv_data = CSV.generate do |csv|
      csv << @file_headers
      @data_to_export.each do |model_obj|
        row_values = declared_fields.collect { |field| ((model_obj[field.to_sym]).instance_of? Time) ?
            (model_obj[field.to_sym].strftime("%d-%b-%Y"))
        : \
              (model_obj[field.to_sym].to_s.strip) }
        if @serial_number_column_needed
           row_values.unshift row_count
           row_count = row_count + 1
        end
        csv << row_values
      end
    end
    csv_data
  end

  def export_data
    if (@data_to_export.length > 0 and @file_headers.length > 0 and @file_name != nil and @model != nil)
      declared_fields = @model.fields.select_map {
          |field| field[1].name if field[1].name != '_id' && field[1].name != '_type' && field[1].name != 'nil'
      }

      csv_data = stream_data(declared_fields)

      file_name = @file_name + "_" + Time.now.strftime(TIME_FORMAT) + FILE_EXTENSION
      send_data(csv_data, :type=>TYPE_HEADER, :disposition=>'attachment', :filename => file_name)
    end
  end

end