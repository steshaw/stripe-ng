module Stripe.Billing.Coupons where
import Stripe.Core
import Stripe.Utils

data CouponDuration
  = Forever
  | Once
  | Repeating
  deriving (Show, Eq, Generic, Typeable)

instance FromJSON CouponDuration where
  parseJSON = withText "CouponDuration" $ \t -> case t of
    "forever" -> pure Forever
    "once" -> pure Once
    "repeating" -> pure Repeating
    _ -> fail ("Invalid CouponDuration: " ++ show t)

data Coupon = Coupon
  { couponId :: Id Coupon
  , couponAmountOff :: Maybe Integer
  , couponCreated :: Timestamp
  , couponCurrency :: Maybe CurrencyCode
  -- TODO coalesce months amount into duration
  , couponDuration :: CouponDuration
  , couponDurationInMonths :: Maybe Integer
  , couponLiveMode :: Bool
  , couponMaxRedemptions :: Maybe Word
  , couponMetadata :: Metadata
  , couponName :: Maybe Text
  , couponPercentOff :: Maybe Double
  , couponRedeemBy :: Maybe Timestamp
  , couponTimesRedeemed :: Integer
  , couponValid :: Bool
  } deriving (Show, Eq, Generic, Typeable)

instance FromJSON Coupon where
  parseJSON = parseObject "Coupon" $ do
    assertObject "coupon"
    Coupon
      <$> req "id"
      <*> req "amount_off"
      <*> req "created"
      <*> req "currency"
      <*> req "duration"
      <*> opt "duration_in_months"
      <*> req "livemode"
      <*> opt "max_redemptions"
      <*> req "metadata"
      <*> opt "name"
      <*> opt "percent_off"
      <*> opt "redeem_by"
      <*> req "times_redeemed"
      <*> req "valid"


-- createCoupon

retrieveCoupon :: (MonadStripe m, StripeResult Coupon coupon) => Id Coupon -> m coupon
retrieveCoupon (Id couponId) = stripeGet (Proxy @Coupon) ("coupons/" <> encodeUtf8 couponId) []

-- updateCoupon
-- deleteCoupon

listAllCoupons :: (MonadStripe m, StripeResult (List Coupon) couponList) => Pagination Coupon -> m couponList
listAllCoupons = stripeGet (Proxy @(List Coupon)) "coupons" . paginationParams
