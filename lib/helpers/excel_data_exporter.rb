module ExcelDataExporter
  DATE_FORMAT = "%d-%b-%Y"
  FILE_EXTENSION = ".xls"

  def export_xls(model,headers)
    respond_to do |format|
      format.xls { send_data model.all.to_xls(
                                 :headers => headers,
                                 :columns => declared_fields(model)
                             ),
                              :filename => model.to_s+'_'+Time.now.strftime(DATE_FORMAT) + FILE_EXTENSION}
    end
  end

  def declared_fields(model)
    model.fields.select_map {
      |field| field[1].name if !['_id','_type','nil'].include?(field[1].name)
    }
  end
end
