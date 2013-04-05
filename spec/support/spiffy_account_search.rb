class SpiffyAccountSearch < AccountSearch

  searches :spiffiness

  def search_spiffiness
    search.where(spiffiness: spiffiness)
  end

end
