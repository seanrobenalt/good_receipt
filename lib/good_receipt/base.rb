require 'prawn'
require 'prawn/table'
require_relative 'constants'
require_relative 'index'

module GoodReceipt
  class Configuration
    attr_accessor :business_name, :business_phone, :business_email, :storage_bucket, :storage_project_id,
                  :storage_credentials

    def initialize
      @business_name = 'Business Name'
      @business_phone = '(000) 111-1234'
      @business_email = 'email@email.com'
      @storage_project_id = 'google-cloud-project'
      @storage_bucket = 'google-cloud-bucket-name'
      @storage_credentials = '/path/to/credentials'
    end
  end

  class ReceiptError < StandardError; end

  class ReceiptDataError < ReceiptError; end

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  def initialize
    @configuration = self.class.configuration
  end

  class Base
    private

    def pdf
      @pdf ||= setup_pdf
    end

    def header_info_column(data)
      pdf.make_table(data, cell_style: { border_width: 0 }) do
        cells.style(size: 34)
        cells.style do |c|
          if (c.row % 2).zero?
            c.text_color = Constants::COLOR_GRAY
          else
            c.font_style = :bold
            c.padding_bottom = 15
          end
        end
      end
    end

    def header(title, data)
      data = data.map { |col| col.map { |item| [item] } }
      col1 = header_info_column(data[0])
      col2 = pdf.make_table(data[1], position: :right, cell_style: { border_width: 0 }) do
        cells.style(size: 35, align: :right)
      end

      pdf.table(
        [
          [title, '', { image: './images/main.png', position: :right }],
          [col1, '', col2]
        ],
        width: pdf.bounds.width,
        cell_style: { border_width: 0 }
      ) do
        row(0).font_style = :bold
        row(0).size = 59
        row(0).text_color = Constants::COLOR_DEFAULT
      end

      pdf.move_down 80
    end

    def report_header(title, meta_info)
      if GoodReceipt.configuration.nil?
        raise StandardError, 'Configuration not set. Please call GoodReceipt.configure to set the configuration.'
      end

      dt = meta_info[:date] || Time.now.getlocal('-06:00').strftime('%Y-%m-%d %I:%M%P').to_s

      header(
        title,
        [
          [
            'Customer Name', meta_info[:customer_name],
            'Date', dt
          ],
          [
            GoodReceipt.configuration.business_name, GoodReceipt.configuration.business_phone, GoodReceipt.configuration.business_email
          ]
        ]
      )
    end

    def space(height = 30)
      pdf.move_down height
    end

    def hr_line
      pdf.stroke do
        pdf.stroke_color Constants::COLOR_DEFAULT
        pdf.line_width 10
        pdf.stroke_horizontal_rule
      end
      space
    end

    def section_title(text, underline: false)
      pdf.text text, size: 60, color: Constants::COLOR_DEFAULT
      space
      hr_line if underline
    end

    def list(data, text_color: Constants::COLOR_DEFAULT)
      pdf.table(data, width: pdf.bounds.width, cell_style: { inline_format: true }) do
        cells.size = 39
        cells.borders = [:bottom]
        cells.border_color = Constants::COLOR_TABLE_BORDER
        cells.border_width = 4
        cells.padding_bottom = 20
        cells.padding_top = 50
        cells.font_style = :bold

        columns(0).text_color = text_color
        columns(0).padding_left = 30
        columns(1).text_color = Constants::COLOR_GRAY
        columns(1).padding_right = 30
        columns(1).align = :right
      end

      space
    end

    def conditions_list(data, text_color: Constants::COLOR_DEFAULT)
      hr_line

      pdf.table(data, width: pdf.bounds.width, cell_style: { inline_format: true }) do
        cells.size = 30
        cells.borders = [:bottom]
        cells.border_color = Constants::COLOR_TABLE_BORDER
        cells.border_width = 4
        cells.padding_bottom = 20
        cells.padding_top = 50
        cells.font_style = :bold

        columns(0).text_color = text_color
        columns(0).padding_left = 30
        columns(1).text_color = Constants::COLOR_GRAY
        columns(1).padding_right = 30
        columns(1).align = :right
        columns(2).align = :right
        columns(3).align = :right
      end
    end

    def price_table(data)
      cols = data.first.count
      last_col = cols - 1
      pdf.table(data, width: pdf.bounds.width, cell_style: { inline_format: true }) do
        cells.size = 39
        cells.borders = [:bottom]
        cells.border_color = Constants::COLOR_TABLE_BORDER
        cells.border_width = 4
        cells.padding_bottom = 20
        cells.padding_top = 50
        cells.text_color = Constants::COLOR_GRAY

        row(0).font_style = :bold

        column(0).font_style = :bold
        column(0).text_color = Constants::COLOR_DEFAULT
        column(0).padding_left = 30

        column(1..last_col).align = :right
        column(1..last_col).width = 350

        column(last_col).padding_right = 30
        column(last_col).font_style = :bold

        row(0).text_color = Constants::COLOR_BLACK
        row(0).border_color = Constants::COLOR_BLACK
      end
      pdf.move_down 80
    end

    def setup_pdf
      pdf = Prawn::Document.new(
        page_size: [2480, 3508],
        margin: [140, 180]
      )
      pdf.font_families.update('AvenirNext' => {
                                 normal: './fonts/AvenirNext/regular.ttf',
                                 bold: './fonts/AvenirNext/bold.ttf',
                                 italic: './fonts/AvenirNext/italic.ttf'
                               })

      pdf.font 'AvenirNext'
      pdf
    end
  end
end
