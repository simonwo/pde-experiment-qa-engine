require 'sxp'

class QueryParser
  def parse sexp
    # TODO: limit on expression size/processing time
    SXP::Reader::Scheme.read sexp
  end
end