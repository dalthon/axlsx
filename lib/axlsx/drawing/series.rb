# encoding: UTF-8
module Axlsx
  # A Series defines the common series attributes and is the super class for all concrete series types.
  # @note The recommended way to manage series is to use Chart#add_series
  # @see Worksheet#add_chart
  # @see Chart#add_series
  class Series

    # The chart that owns this series
    # @return [Chart]
    attr_reader :chart

    # The title of the series
    # @return [SeriesTitle]
    attr_reader :title

    # Creates a new series
    # @param [Chart] chart
    # @option options [Integer] order
    # @option options [String] title
    def initialize(chart, options={})
      @order = nil
      self.chart = chart
      @chart.series << self
      options.each do |o|
        self.send("#{o[0]}=", o[1]) if self.respond_to? "#{o[0]}="
      end
    end


    # The index of this series in the chart's series.
    # @return [Integer]
    def index
      @chart.series.index(self)
    end


    # The order of this series in the chart's series. By default the order is the index of the series.
    # @return [Integer]
    def order
      @order || index
    end

    # @see order
    def order=(v)  Axlsx::validate_unsigned_int(v); @order = v; end

    # @see title
    def title=(v)
      v = SeriesTitle.new(v) if v.is_a?(String) || v.is_a?(Cell)
      DataTypeValidator.validate "#{self.class}.title", SeriesTitle, v
      @title = v
    end

    def error_x?
      @error_x
    end

    def error_x=(opts)
      initialize_errors
      @error_x = true
      @lower_errors[:x]  = opts[:lower]
      @higher_errors[:x] = opts[:higher]
    end


    def error_y?
      @error_y
    end

    def error_y=(opts)
      initialize_errors
      @error_y = true
      @lower_errors[:y]  = opts[:lower]
      @higher_errors[:y] = opts[:higher]
    end
    private

    def error_bars(val)
      "<c:errBars>
        <c:errDir val=\"#{val}\"/>
        <c:errBarType val=\"both\"/>
        <c:errValType val=\"cust\"/>
        <c:noEndCap val=\"0\"/>
        <c:plus>
          <c:numRef>
            <c:f>#{@lower_errors[val]}</c:f>
          </c:numRef>
        </c:plus>
        <c:minus>
          <c:numRef>
            <c:f>#{@higher_errors[val]}</c:f>
          </c:numRef>
        </c:minus>
      </c:errBars>"
    end

    def initialize_errors
      @lower_errors ||= {}
      @higher_errors ||= {}
    end

    # assigns the chart for this series
    def chart=(v)  DataTypeValidator.validate "Series.chart", Chart, v; @chart = v; end

    # Serializes the object
    # @param [String] str
    # @return [String]
    def to_xml_string(str = '')
      str << '<c:ser>'
      str << '<c:idx val="' << index.to_s << '"/>'
      str << '<c:order val="' << (order || index).to_s << '"/>'
      str << error_bars(:x) if error_x?
      str << error_bars(:y) if error_y?
      title.to_xml_string(str) unless title.nil?
      yield str if block_given?
      str << '</c:ser>'
    end
  end

end
