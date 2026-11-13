import graphene
from graphene_django import DjangoObjectType
from graphql import GraphQLError
from .models import Notification

class NotificationNodeType(DjangoObjectType):
    class Meta:
        model = Notification
        fields = (
            'id', 'recipient', 'title', 'body', 'notification_type',
            'is_read', 'related_id', 'created_at'
        )

class Query(graphene.ObjectType):
    my_notifications = graphene.List(NotificationNodeType, unread_only=graphene.Boolean(default_value=False))
    unread_notification_count = graphene.Int()

    def resolve_my_notifications(self, info, unread_only=False):
        user = info.context.user
        if user.is_anonymous:
            raise GraphQLError("Lazima uwe umeingia kwenye akaunti.")
        qs = Notification.objects.filter(recipient=user)
        if unread_only:
            qs = qs.filter(is_read=False)
        return qs

    def resolve_unread_notification_count(self, info):
        user = info.context.user
        if user.is_anonymous:
            return 0
        return Notification.objects.filter(recipient=user, is_read=False).count()

class MarkNotificationAsRead(graphene.Mutation):
    class Arguments:
        id = graphene.ID(required=True)

    success = graphene.Boolean()
    message = graphene.String()

    def mutate(self, info, id):
        user = info.context.user
        if user.is_anonymous:
            raise GraphQLError("Lazima uwe umeingia kwenye akaunti.")

        try:
            notification = Notification.objects.get(pk=id, recipient=user)
            notification.is_read = True
            notification.save()
            return MarkNotificationAsRead(success=True, message="Arifa imetiwa alama kama imesomwa.")
        except Notification.DoesNotExist:
            raise GraphQLError("Arifa haikupatikana.")

class MarkAllNotificationsAsRead(graphene.Mutation):
    success = graphene.Boolean()
    message = graphene.String()

    def mutate(self, info):
        user = info.context.user
        if user.is_anonymous:
            raise GraphQLError("Lazima uwe umeingia kwenye akaunti.")

        Notification.objects.filter(recipient=user, is_read=False).update(is_read=True)
        return MarkAllNotificationsAsRead(success=True, message="Arifa zote zimetiwa alama kuwa zimesomwa.")

class Mutation(graphene.ObjectType):
    mark_notification_as_read = MarkNotificationAsRead.Field()
    mark_all_notifications_as_read = MarkAllNotificationsAsRead.Field()

