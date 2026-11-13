import graphene

try:
    import graphql_jwt
    HAS_GRAPHQL_JWT = True
except ImportError:
    HAS_GRAPHQL_JWT = False

import apps.accounts.schema
import apps.listings.schema
import apps.bookings.schema
import apps.payments.schema
import apps.reviews.schema
import apps.notifications.schema

class RootQuery(
    apps.accounts.schema.Query,
    apps.listings.schema.Query,
    apps.bookings.schema.Query,
    apps.payments.schema.Query,
    apps.reviews.schema.Query,
    apps.notifications.schema.Query,
    graphene.ObjectType,
):
    pass

class RootMutation(
    apps.accounts.schema.Mutation,
    apps.listings.schema.Mutation,
    apps.bookings.schema.Mutation,
    apps.payments.schema.Mutation,
    apps.reviews.schema.Mutation,
    apps.notifications.schema.Mutation,
    graphene.ObjectType,
):
    pass

if HAS_GRAPHQL_JWT:
    RootMutation.token_auth = graphql_jwt.ObtainJSONWebToken.Field()
    RootMutation.verify_token = graphql_jwt.Verify.Field()
    RootMutation.refresh_token = graphql_jwt.Refresh.Field()

schema = graphene.Schema(query=RootQuery, mutation=RootMutation)
