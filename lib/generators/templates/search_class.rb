class <%= class_name %>Search < Searchlight::Search
  #search_on <%= class_name %>

  #Model attributes for which you want to search
  #searches :gender, :city_id, :firstname

  #Examples
  #def search_gender
  #  search.where(:gender => gender)
  #end

  #def search_city_id
  #  search.where(city_id: city_id)
  #end

  #def search_firstname
  #  search.where('firstname LIKE ?', '%'+firsname.to_s+'%')
  #end
end
