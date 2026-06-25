from django.db import models
import os
from django.contrib.auth.models import User
from django.db.models.signals import post_save
from django.dispatch import receiver
from django.core.files.storage import default_storage
from django.core.files.base import ContentFile


class UserProfile(models.Model):
    """Профиль пользователя с дополнительной информацией"""
    
    # Связь с моделью User (один к одному)
    user = models.OneToOneField(
        User, 
        on_delete=models.CASCADE,  # При удалении пользователя удалится и профиль
        related_name='profile'      # Позволяет обращаться user.profile
    )
    
    
    class Meta:
        verbose_name = 'Профиль пользователя'
        verbose_name_plural = 'Профили пользователей'

@receiver(post_save, sender=User)
def create_user_profile(sender, instance, created, **kwargs):
    """Создает профиль пользователя при создании нового пользователя"""
    if created:
        UserProfile.objects.create(user=instance)
@receiver(post_save, sender=User)
def save_user_profile(sender, instance, **kwargs):
    """Сохраняет профиль пользователя при сохранении пользователя"""
    instance.profile.save()



# -------------------- ДОКУМЕНТЫ --------------------
class Document(models.Model):
    name = models.TextField()
    checkan = models.TextField(blank=True, null=True)
    
    class Meta:
        managed = False
        db_table = 'document'


# -------------------- ДОГОВОР --------------------
class Dogovor(models.Model):
    #profile = models.ForeignKey('UserProfile', on_delete=models.CASCADE, 
    #                            related_name='dogovor_records', null=True, blank=True)  # Уникальное имя
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    org = models.TextField(blank=True, null=True)
    adress = models.TextField(blank=True, null=True)
    smart = models.TextField(blank=True, null=True)
    rec = models.TextField(blank=True, null=True)
    rycov = models.TextField(blank=True, null=True)
    doljnost_profruk = models.TextField(db_column='doljnost_profRuk', blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'dogovor'
        def __str__(self):
            return self.title


# -------------------- ПРИЛОЖЕНИЕ --------------------
class Prilojenie12(models.Model):
    #profile = models.ForeignKey('UserProfile', on_delete=models.CASCADE, 
    #                            related_name='prilojenie_records', null=True, blank=True)  # Уникальное имя
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    module = models.ForeignKey('Modules', on_delete=models.SET_NULL, null=True, blank=True)
    start = models.DateField(blank=True, null=True)  
    year = models.IntegerField(blank=True, null=True)
    final = models.DateField(blank=True, null=True)  
    
    akd = models.IntegerField(blank=True, null=True)
    fio_stud = models.TextField(blank=True, null=True)
    date_birth = models.DateField(blank=True, null=True)  
    fioruk = models.TextField(db_column='fioRuk', blank=True, null=True)
    num_ruk = models.IntegerField(blank=True, null=True)
    fioprofruk = models.TextField(db_column='fioProfRuk', blank=True, null=True)
    doljnost_profruk = models.TextField(db_column='doljnost_profRuk', blank=True, null=True)
    numprofruk = models.TextField(db_column='numProfRuk', blank=True, null=True)
    org = models.TextField(blank=True, null=True)
    fiootv = models.TextField(db_column='fioOtv', blank=True, null=True)
    doljotv = models.TextField(db_column='doljOtv', blank=True, null=True)
    numberotv = models.TextField(db_column='numberOtv', blank=True, null=True)
    addres = models.TextField(blank=True, null=True)
    namepomech = models.TextField(db_column='namePomech', blank=True, null=True)
    direction = models.ForeignKey('Naprav', on_delete=models.SET_NULL, null=True, blank=True)


    class Meta:
        managed = False
        db_table = 'prilojenie12'
        def __str__(self):
            return self.title


# -------------------- ЛИСТ КОНТРОЛЯ --------------------
class ListKontrol(models.Model):
    #profile = models.ForeignKey('UserProfile', on_delete=models.CASCADE, 
    #                            related_name='list_kontrol_records', null=True, blank=True)  # Уникальное имя
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    gru = models.TextField(blank=True, null=True)
    date = models.TextField(blank=True, null=True)
    fio_ruk = models.TextField(blank=True, null=True)
    prohod_pract = models.TextField(blank=True, null=True)
    org = models.TextField(blank=True, null=True)
    ryk_p = models.TextField(blank=True, null=True)
    fioprisut = models.TextField(blank=True, null=True)
    fio_ots = models.TextField(blank=True, null=True)
    prichina = models.TextField(blank=True, null=True)
    direction = models.ForeignKey('Naprav', on_delete=models.SET_NULL, null=True, blank=True)

    class Meta:
        managed = False
        db_table = 'list_kontrol'# This is an auto-generated Django model module.
        def __str__(self):
            return self.title
from django.db import models


class Students(models.Model):
    otchestvo = models.TextField(blank=True, null=True)
    familia = models.TextField(blank=True, null=True)
    name = models.TextField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'students'
        def __str__(self):
            return self.title
# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Make sure each ForeignKey and OneToOneField has `on_delete` set to the desired behavior
#   * Remove `managed = False` lines if you wish to allow Django to create, modify, and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.
from django.db import models




from django.db import models


class AuthUser(models.Model):
    password = models.CharField(max_length=128)
    last_login = models.DateTimeField(blank=True, null=True)
    is_superuser = models.BooleanField()
    username = models.CharField(unique=True, max_length=150)
    last_name = models.CharField(max_length=150)
    email = models.CharField(max_length=254)
    is_staff = models.BooleanField()
    is_active = models.BooleanField()
    date_joined = models.DateTimeField()
    first_name = models.CharField(max_length=150)

    class Meta:
        managed = False
        db_table = 'auth_user'


DOCUMENT_TYPES = (
    ('contract', 'Договор'),
    ('appendix', 'Приложение'),
    ('control', 'Лист контроля'),
)

class DocumentTemplate(models.Model):
    title = models.CharField(max_length=255)

    template_file = models.FileField(
        upload_to='templates/documents/'
    )

    doc_type = models.CharField(
        max_length=20,
        choices=DOCUMENT_TYPES,
        default='contract'
    )

    description = models.TextField(blank=True)
    uploaded_at = models.DateTimeField(auto_now_add=True)

    uploaded_by = models.ForeignKey(
        User,
        on_delete=models.SET_NULL,
        null=True
    )

    def str(self):
        return self.title


class Modules(models.Model):
    name = models.TextField()

    class Meta:
        managed = False
        db_table = 'modules'


class Naprav(models.Model):
    name_naprav = models.CharField(blank=True, null=True)
    kod = models.TextField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'naprav'
