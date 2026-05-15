from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from . import views

urlpatterns = [
    # Auth
    path('register', views.RegisterView.as_view(), name='register'),
    path('login', views.LoginView.as_view(), name='login'),
    path('token/refresh', TokenRefreshView.as_view(), name='token_refresh'),

    # Profile
    path('profile', views.ProfileView.as_view(), name='profile'),
    path('profile/update', views.ProfileView.as_view(), name='profile_update'),

    # Missions
    path('missions', views.MissionListCreateView.as_view(), name='missions'),
    path('missions/<int:pk>', views.MissionDetailView.as_view(), name='mission_detail'),

    # Candidatures
    path('apply', views.ApplyView.as_view(), name='apply'),
    path('mission/<int:pk>/applications', views.MissionApplicationsView.as_view(), name='applications'),

    # Messages
    path('messages', views.MessageListCreateView.as_view(), name='messages'),
    path('conversations', views.ConversationListView.as_view(), name='conversations'),

    # Paiements
    path('pay', views.PaiementView.as_view(), name='pay'),
    path('payments', views.PaiementView.as_view(), name='payments'),

    # Avis
    path('review', views.AvisView.as_view(), name='review'),

    # Dashboard
    path('dashboard', views.DashboardView.as_view(), name='dashboard'),
]
