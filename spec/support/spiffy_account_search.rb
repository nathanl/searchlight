class SpiffyAccountSearch < AccountSearch

  searches :spiffiness

  def spiffiness_search
    results.where(spiffiness: spiffiness)
  end

end
