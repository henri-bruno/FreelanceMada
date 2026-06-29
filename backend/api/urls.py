from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from . import views

urlpatterns = [
    # ── Auth ──────────────────────────────────────────────────
    path('auth/register/', views.RegisterView.as_view(), name='register'),
    path('auth/login/', views.LoginView.as_view(), name='login'),
    path('auth/logout/', views.LogoutView.as_view(), name='logout'),
    path('auth/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('auth/change-password/', views.ChangePasswordView.as_view(), name='change_password'),

    # ── Profil ────────────────────────────────────────────────
    path('me/', views.MeView.as_view(), name='me'),
    path('users/<int:pk>/', views.UserDetailView.as_view(), name='user_detail'),
    path('freelances/', views.FreelanceListView.as_view(), name='freelance_list'),

    # ── Certifications ───────────────────────────────────────
    path('certifications/', views.CertificationView.as_view()),
    path('certifications/<int:pk>/', views.CertificationDetailView.as_view()),

    # ── Expériences ──────────────────────────────────────────
    path('experiences/', views.ExperienceView.as_view()),
    path('experiences/<int:pk>/', views.ExperienceDetailView.as_view()),

    # ── Portfolio ────────────────────────────────────────────
    path('portfolio/', views.PortfolioView.as_view()),
    path('portfolio/<int:pk>/', views.PortfolioDetailView.as_view()),

    # ── Missions ─────────────────────────────────────────────
    path('missions/', views.MissionListView.as_view(), name='mission_list'),
    path('missions/<int:pk>/', views.MissionDetailView.as_view(), name='mission_detail'),
    path('missions/<int:mission_id>/fichiers/', views.MissionFichierUploadView.as_view()),

    # ── Services ─────────────────────────────────────────────
    path('services/', views.ServiceListView.as_view(), name='service_list'),
    path('services/<int:pk>/', views.ServiceDetailView.as_view(), name='service_detail'),
    path('services/<int:service_id>/packages/', views.ServicePackageView.as_view()),

    # ── Candidatures ─────────────────────────────────────────
    path('candidatures/', views.CandidatureListView.as_view(), name='candidature_list'),
    path('candidatures/<int:pk>/', views.CandidatureDetailView.as_view(), name='candidature_detail'),

    # ── Contrats ─────────────────────────────────────────────
    path('contrats/', views.ContratListView.as_view(), name='contrat_list'),
    path('contrats/<int:pk>/', views.ContratDetailView.as_view(), name='contrat_detail'),
    path('contrats/<int:contrat_id>/livraisons/', views.ContratLivraisonView.as_view()),

    # ── Messages ─────────────────────────────────────────────
    path('conversations/', views.ConversationListView.as_view()),
    path('messages/<int:user_id>/', views.MessageListView.as_view()),
    path('messages/msg/<int:pk>/', views.MessageDetailView.as_view()),

    # ── Paiements ────────────────────────────────────────────
    path('paiements/', views.PaiementListView.as_view()),
    path('paiements/<int:pk>/', views.PaiementDetailView.as_view()),

    # ── Avis ─────────────────────────────────────────────────
    path('avis/', views.AvisListView.as_view()),

    # ── Notifications ────────────────────────────────────────
    path('notifications/', views.NotificationListView.as_view()),
    path('notifications/read/', views.NotificationMarkReadView.as_view()),
    path('notifications/<int:pk>/read/', views.NotificationMarkReadView.as_view()),

    # ── Dashboard ────────────────────────────────────────────
    path('dashboard/', views.DashboardView.as_view()),

    # ── Catégories ───────────────────────────────────────────
    path('categories/', views.CategorieListView.as_view()),

    # ── Favoris ──────────────────────────────────────────────
    path('favoris/', views.FavoriListView.as_view()),
    path('favoris/<int:pk>/', views.FavoriDetailView.as_view()),

    # ── Signalements ─────────────────────────────────────────
    path('signalements/', views.SignalementView.as_view()),

    # ── Recherche ────────────────────────────────────────────
    path('search/', views.SearchView.as_view()),
]
