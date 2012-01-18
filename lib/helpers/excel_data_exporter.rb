module ExcelDataExporter
  FILE_EXTENSION = ".xls"

  def export_xls(model,headers)
    declared_fields = model.fields.select_map {
      |field| field[1].name if !['_id','_type','nil'].include?(field[1].name)
    }
    respond_to do |format|
      format.xls { send_data @data_to_export.to_xls(:headers => headers,
        :columns => declared_fields),
      :filename => model.to_s+FILE_EXTENSION}
    end
  end
end
