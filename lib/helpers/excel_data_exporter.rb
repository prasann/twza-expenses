module ExcelDataExporter
  FILE_EXTENSION = ".xls"

  def export_xls(data_to_export, headers, options)
    respond_to do |format|
      format.xls do
        model = options[:model]
        filename_prefix = options[:filename_prefix] || model
        exportable_fields = options[:exportable_fields] || model.fields.select_map { |field| field[1].name if !['_id', '_type', 'nil'].include?(field[1].name) }
        send_data(data_to_export.to_xls(:headers => headers, :columns => exportable_fields),
                  :filename => "#{filename_prefix}_#{DateHelper.date_fmt(Date.today)}#{FILE_EXTENSION}")
      end
    end
  end
end
