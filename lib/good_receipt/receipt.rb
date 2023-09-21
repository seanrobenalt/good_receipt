require_relative 'index'
require_relative 'base'
require 'google/cloud/storage'

module GoodReceipt
  class Receipt < Base
    def initialize(data)
      super()
      validate_data(data)
      @data = data
    end

    def table_items
      items = [
        ['Description', 'Qty', 'Unit Price', 'Line Total']
      ]

      @data[:line_items].each do |line_item|
        items << [line_item[:name], '', '', '']

        total = 0.0

        line_item[:items].each do |item|
          total += item[:price].to_f
          items << [item[:name], item[:quantity], "$#{item[:price]}",
                    "$#{(item[:price] * item[:quantity]).to_f.round(2)}"]
        end

        items << ['', '', '', "$#{total.round(2)}"]
      end

      items << ['', '', 'Discount', "- $#{@data[:discount].to_f.round(2)}"] if @data[:discount]

      items << ['', '', 'Tax', "$#{@data[:tax]}"] if @data[:tax]

      items << ['', '', 'Total Price', "$#{@data[:total_price]}"]
    end

    def paid_line
      pdf.table(
        [
          ['', 'PAID']
        ],
        width: pdf.bounds.width,
        cell_style: { border_width: 0 }
      ) do
        column(0).size = 40

        column(1).align = :right
        column(1).size = 70
        column(1).text_color = Constants::COLOR_GREEN
        column(1).font_style = :bold
        column(1).padding_right = 50
      end
    end

    def generate
      # Render PDF
      report_header(
        'Receipt',
        {
          customer_name: @data[:customer_name],
          date: @data[:date]
        }
      )
      price_table(table_items)
      paid_line

      # Save PDF into the file
      path_name = "receipt-#{@data[:id]}.pdf"
      pdf.render_file path_name

      # Store PDF into the Google Cloud Storage
      storage = ::Google::Cloud::Storage.new(
        project_id: GoodReceipt.configuration.storage_project_id,
        credentials: GoodReceipt.configuration.storage_credentials
      )

      bucket = storage.bucket GoodReceipt.configuration.storage_bucket
      file = bucket.create_file path_name, "/#{@id}/receipt.pdf"
      file.acl.public!

      # Return the URL of the PDF
      file.url
    end

    private

    def validate_data(data)
      raise ReceiptDataError, "Invalid data format: #{data.inspect}. Data must be a hash." unless data.is_a?(Hash)
      raise ReceiptDataError, "Invalid data format: #{data.inspect}" unless valid_data?(data)
    end

    def valid_data?(data)
      expected_keys = %i[line_items customer_name discount total_price date id]
      unless expected_keys.all? { |key| data.key?(key) }
        raise ReceiptDataError,
              "Missing or invalid key(s) in data: #{data.keys.inspect}. Expected keys: #{expected_keys.inspect}"
      end

      unless valid_line_items?(data[:line_items])
        raise ReceiptDataError,
              "Invalid format in line_items: #{data[:line_items].inspect}. Each item should be a hash with :name and :items keys."
      end

      true
    end

    def valid_line_items?(line_items)
      unless line_items.is_a?(Array) &&
             line_items.all? { |item| item.is_a?(Hash) && item.key?(:name) && item.key?(:items) }
        raise ReceiptDataError,
              "Invalid format in line_items: #{line_items.inspect}. Each item should be a hash with :name and :items keys."
      end

      true
    end
  end
end
