from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from django.contrib.auth.models import User
from .models import UserProfile, DocumentTemplate, Dogovor, Prilojenie12, ListKontrol




admin.site.unregister(User)

# Теперь регистрируем с кастомным классом
@admin.register(User)
class CustomUserAdmin(UserAdmin):
    """
    Расширяем стандартный UserAdmin для добавления новых колонок в список.
    """
    list_display = ('username', 'email', 'first_name', 'last_name', 'is_staff', 'date_joined')
    list_filter = ('is_staff', 'is_superuser', 'is_active', 'date_joined')
    search_fields = ('username', 'first_name', 'last_name', 'email')
    fieldsets = UserAdmin.fieldsets + (
        ('Дополнительная информация', {'fields': ()}),
    )

# Регистрируем остальные модели
@admin.register(DocumentTemplate)
class DocumentTemplateAdmin(admin.ModelAdmin):
    list_display = ('title', 'doc_type', 'uploaded_at', 'uploaded_by')
    list_filter = ('doc_type', 'uploaded_at', 'uploaded_by')
    search_fields = ('title', 'description')
    readonly_fields = ('uploaded_at',)
    
    def save_model(self, request, obj, form, change):
        if not obj.pk:  # Если объект только создается
            obj.uploaded_by = request.user
        super().save_model(request, obj, form, change)

@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    list_display = ('id', 'user')
    search_fields = ('user__username', 'familia', 'name', 'otchestvo')

@admin.register(Dogovor)
class DogovorAdmin(admin.ModelAdmin):
    list_display = ('user', 'org', 'adress')
    search_fields = ('user__username', 'org')

@admin.register(Prilojenie12)
class Prilojenie12Admin(admin.ModelAdmin):
    list_display = ('user', 'module', 'fio_stud')
    search_fields = ('user__username', 'fio_stud')

@admin.register(ListKontrol)
class ListKontrolAdmin(admin.ModelAdmin):
    list_display = ('user', 'gru', 'org')
    search_fields = ('user__username', 'gru', 'org')


    