module ExcelDataExporter
  FILE_EXTENSION = ".xls"
  MASKED_FIELD_NAMES = ['_id', '_type', 'nil']

  def export_xls(data_to_export, headers, options)
    respond_to do |format|
      format.xls do
        model = options[:model]
        filename_prefix = options[:filename_prefix] || model
        exportable_fields = options[:exportable_fields] || model.fields.keys.select { |name| name if !MASKED_FIELD_NAMES.include?(name) }
        send_data(data_to_export.to_xls(:headers => headers, :columns => exportable_fields),
                  :filename => "#{filename_prefix}_#{DateHelper.date_fmt(Date.today)}#{FILE_EXTENSION}")
      end
    end
  end
end
