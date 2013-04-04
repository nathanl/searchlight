class SpiffyAccountSearch < AccountSearch

  searches :spiffiness

  def spiffiness_search
    search.where(spiffiness: spiffiness)
  end

end
