import graphene
import graphql_jwt

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
    # JWT authentication mutations
    token_auth = graphql_jwt.ObtainJSONWebToken.Field()
    verify_token = graphql_jwt.Verify.Field()
    refresh_token = graphql_jwt.Refresh.Field()

schema = graphene.Schema(query=RootQuery, mutation=RootMutation)

