class ProcSearch < Searchlight::Search

  searches :first_name

  search_on proc { MockModel.some_scope }

  def search_first_name
    search.where(first_name: first_name)
  end

end

class ChildProcSearch < ProcSearch

  search_on proc { superclass.search_target.call.other_scope }

end
