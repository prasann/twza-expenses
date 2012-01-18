module ExcelDataExporter
  FILE_EXTENSION = ".xls"
  
  def export_xls(model,headers)
    declared_fields = model.fields.select_map {
      |field| field[1].name if field[1].name != '_id' && field[1].name != '_type' && field[1].name != 'nil'
    }
    respond_to do |format|
      format.xls { send_data model.all.to_xls(:headers => headers,
        :columns => declared_fields),
      :filename => model.to_s+FILE_EXTENSION}
    end
  end
end
