# Good Receipt Gem

The "good_receipt" gem is a Ruby library for generating and managing receipts. This document provides instructions on how to install the gem, set configuration variables, retrieve a Google Cloud Storage key file, and use the `GoodReceipt::Receipt` class to create receipts.

## Installation

`gem install good_receipt`

### Configuration

Before using the gem, you should configure it with the following variables:

- `business_name`: Name of your business.
- `business_phone`: Business phone number.
- `business_email`: Business email address.
- `storage_project_id`: Google Cloud project ID.
- `storage_bucket`: Google Cloud Storage bucket name.
- `storage_credentials`: Path to your Google Cloud Storage key file.

To set the configuration variables, you can use the `GoodReceipt.configure` block in a configuration file in your Ruby code:

```ruby
require 'good_receipt'

GoodReceipt.configure do |config|
  config.business_name = 'Your Business Name'
  config.business_phone = '(000) 111-1234'
  config.business_email = 'business@example.com'
  config.storage_project_id = 'your-project-id'
  config.storage_bucket = 'your-bucket-name'
  config.storage_credentials = '/path/to/your/credentials.json'
end
```

### Retrieve Google Cloud Storage Key File

To retrieve a Google Cloud Storage key file, you'll need to:

- [Create a Google Cloud project](https://console.cloud.google.com/getting-started?pli=1)
- [Create a storage bucket in your project](https://cloud.google.com/storage/docs/creating-buckets)
- [Create a service account in your project](https://cloud.google.com/iam/docs/service-accounts-create).
- [Create a JSON key for your service account](https://cloud.google.com/iam/docs/reference/rest/v1/projects.serviceAccounts.keys)

Ensure that the key file is stored in a secure location and is accessible for authentication. You'll need to pass the path to your file to the configuration for `GoodReceipt` in order for your receipt PDFs to be sent to the cloud.

### Creating a Receipt

To create a receipt you'll need to pass your data in specific format to the `GoodReceipt::Receipt` class. If your data is not structured correctly, an error will be thrown with exactly what's expected. Here's an example:

```ruby
receipt_data = {
  line_items: [
    {
      name: 'Salad',
      items: [
        {
          price: 9.99,
          quantity: 1,
          name: 'Salad'
        },
        {
          price: 2.99,
          quantity: 1,
          name: 'Dressing'
        }
      ]
    }
  ],
  customer_name: 'Sean',
  discount: 10, # Optional
  tax: 0.77, # Optional
  total_price: 13.75,
  date: "2023-09-21", # Date of purchase, can be any format
  id: 1 # ID of purchase, used for your unique pathname of PDF
}

instance = GoodReceipt::Receipt.new(receipt_data)
instance.generate # Will generate your PDF and store in the cloud
```

### Contributing
If you would like to contribute to the gem, you can find the project on GitHub.

[GitHub Repository](https://github.com/seanrobenalt/good-receipt)

Feel free to submit issues, create pull requests, or contribute in any way you find valuable. We welcome your contributions!

Thank you for using the gem!
