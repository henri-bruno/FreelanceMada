from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models import User, FreelanceProfile, Mission, Candidature, Message, Paiement, Avis


@admin.register(User)
class UserAdmin(BaseUserAdmin):
    list_display = ['nom', 'email', 'role', 'is_active', 'date_creation']
    list_filter = ['role', 'is_active']
    search_fields = ['nom', 'email']
    ordering = ['-date_creation']
    fieldsets = (
        (None, {'fields': ('email', 'password')}),
        ('Informations', {'fields': ('nom', 'telephone', 'photo', 'role')}),
        ('Permissions', {'fields': ('is_active', 'is_staff', 'is_superuser', 'groups', 'user_permissions')}),
    )
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('email', 'nom', 'role', 'password1', 'password2'),
        }),
    )


@admin.register(FreelanceProfile)
class FreelanceProfileAdmin(admin.ModelAdmin):
    list_display = ['user', 'experience', 'note_moyenne']


@admin.register(Mission)
class MissionAdmin(admin.ModelAdmin):
    list_display = ['titre', 'client', 'budget', 'statut', 'deadline', 'date_creation']
    list_filter = ['statut', 'categorie']
    search_fields = ['titre', 'description']


@admin.register(Candidature)
class CandidatureAdmin(admin.ModelAdmin):
    list_display = ['freelance', 'mission', 'prix_propose', 'statut', 'date_candidature']
    list_filter = ['statut']


@admin.register(Message)
class MessageAdmin(admin.ModelAdmin):
    list_display = ['sender', 'receiver', 'date', 'lu']


@admin.register(Paiement)
class PaiementAdmin(admin.ModelAdmin):
    list_display = ['mission', 'montant', 'statut', 'date']
    list_filter = ['statut']


@admin.register(Avis)
class AvisAdmin(admin.ModelAdmin):
    list_display = ['auteur', 'mission', 'note', 'date']
