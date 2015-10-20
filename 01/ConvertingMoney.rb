def convert_to_bgn(price, currency)
  currencies = {usd: 1.7408, eur: 1.9557, gbp: 2.6415, bgn: 1}
  (price * currencies[currency]).round(2)
end

def compare_prices(price_1, currency_1, price_2, currency_2)
  price_1_bgn = convert_to_bgn(price_1, currency_1)
  price_2_bgn = convert_to_bgn(price_2, currency_2)
  price_1_bgn <=> price_2_bgn
end
