from django.shortcuts import render, redirect, get_object_or_404  # 👈 ДОБАВЬТЕ get_object_or_404
from django.http import HttpResponse
from django.contrib.auth import login, authenticate, logout
from django.contrib import messages
from django.contrib.auth.decorators import login_required
from django.contrib.auth.models import User
from django.contrib.auth.forms import AuthenticationForm  
from .models import Document, Dogovor, Prilojenie12, ListKontrol, UserProfile, Students, DocumentTemplate, Modules, Naprav
from .forms import RegisterForm
from docxtpl import DocxTemplate
from io import BytesIO
from datetime import datetime, date


def mainfNYV(request):
    return HttpResponse("app mainNYV")


def register(request):
    """Регистрация пользователя"""
    if request.method == 'POST':
        form = RegisterForm(request.POST)
        if form.is_valid():
            user = form.save()
            # Автоматический вход после регистрации
            login(request, user)
            messages.success(request, f'Добро пожаловать, {user.username}!')
            return redirect('profile')  # ИСПРАВЛЕНО: redirect вместо render
        else:
            # Если форма не валидна, показываем её с ошибками
            return render(request, 'register.html', {'form': form})
    else:
        form = RegisterForm()
    
    return render(request, 'register.html', {'form': form})



def loginf(request):
    form = AuthenticationForm(request, data=request.POST or None)

    if request.method == 'POST' and form.is_valid():
        login(request, form.get_user())
        return redirect('profile')

    return render(request, 'login.html', {'form': form})


def logout_view(request):
    """Выход из системы"""
    logout(request)
    messages.success(request, 'Вы вышли из системы')
    return redirect('login')  # Убедитесь, что URL с name='login' существует


@login_required
def profile(request):
    """Личный кабинет"""
    try:
        profile = request.user.profile
    except UserProfile.DoesNotExist:
        profile = UserProfile.objects.create(user=request.user)

    pril, _ = Prilojenie12.objects.get_or_create(user=request.user)
    list_kontrol, _ = ListKontrol.objects.get_or_create(user=request.user)
    dogovor, _ = Dogovor.objects.get_or_create(user=request.user)
    templates = DocumentTemplate.objects.all()
    modules_list = Modules.objects.all()
    directions_list = Naprav.objects.all()

    if request.method == 'POST':
        # Сохраняем данные Dogovor
        if 'save_dogovor' in request.POST:
            dogovor.org = request.POST.get('org', '')
            dogovor.adress = request.POST.get('adress', '')
            dogovor.smart = request.POST.get('smart', '')
            dogovor.rec = request.POST.get('rec', '')
            dogovor.rycov = request.POST.get('rycov', '')
            pril.doljnost_profruk = request.POST.get('doljnost_profruk') or None
            dogovor.save()
            messages.success(request, 'Данные договора сохранены')

        # Сохраняем данные Prilojenie12
        elif 'save_pril' in request.POST:
            def parse_date(value):
                if value:
                    return datetime.strptime(value, '%Y-%m-%d').date()
                return None

            def parse_int(value):
                try:
                    return int(value)
                except (TypeError, ValueError):
                    return None

            # Текстовые поля
            pril.modul = request.POST.get('modul') or None
            pril.fio_stud = request.POST.get('fio_stud') or None
            pril.fioruk = request.POST.get('fioruk') or None
            pril.fioprofruk = request.POST.get('fioprofruk') or None
            pril.doljnost_profruk = request.POST.get('doljnost_profruk') or None
            pril.numprofruk = request.POST.get('numprofruk') or None
            pril.org = request.POST.get('org') or None
            pril.fiootv = request.POST.get('fiootv') or None
            pril.doljotv = request.POST.get('doljotv') or None
            pril.numberotv = request.POST.get('numberotv') or None
            pril.addres = request.POST.get('addres') or None
            pril.namepomech = request.POST.get('namepomech') or None

            # Даты
            pril.start = parse_date(request.POST.get('start'))
            pril.final = parse_date(request.POST.get('final'))
            pril.date_birth = parse_date(request.POST.get('date_birth'))

            # Числа
            pril.akd = parse_int(request.POST.get('akd'))
            pril.num_ruk = parse_int(request.POST.get('num_ruk'))
            pril.year = parse_int(request.POST.get('year'))

            # Направление
            direction_id = request.POST.get('direction_id')
            if direction_id and direction_id.isdigit():
                pril.direction_id = int(direction_id)
            else:
                pril.direction_id = None

            # Модуль
            module_id = request.POST.get('module_id')
            if module_id and module_id.isdigit():
                pril.module_id = int(module_id)
            else:
                pril.module_id = None

            pril.save()
            messages.success(request, 'Данные приложения сохранены')

        # Сохраняем данные ListKontrol (исправлены отступы!)
        elif 'save_list' in request.POST:
            list_kontrol.gru = request.POST.get('gru', '')
            list_kontrol.date = request.POST.get('date', '')
            list_kontrol.fio_ruk = request.POST.get('fio_ruk', '')
            list_kontrol.prohod_pract = request.POST.get('prohod_pract', '')
            list_kontrol.org = request.POST.get('org', '')
            list_kontrol.ryk_p = request.POST.get('ryk_p', '')
            list_kontrol.fioprisut = request.POST.get('fioprisut', '')
            list_kontrol.fio_ots = request.POST.get('fio_ots', '')
            list_kontrol.prichina = request.POST.get('prichina', '')

            # Сохраняем выбранное направление
            direction_id = request.POST.get('direction_id')
            if direction_id and direction_id.isdigit():
                list_kontrol.direction_id = int(direction_id)
            else:
                list_kontrol.direction_id = None

            list_kontrol.save()
            messages.success(request, 'Данные листа контроля сохранены')

        return redirect('profile')

    context = {
        'dogovor': dogovor,
        'pril': pril,
        'list': list_kontrol,
        'profile': profile,
        'user': request.user,
        'templates': templates,
        'modules_list': modules_list,
        'directions_list': directions_list,
    }
    return render(request, 'profile.html', context)
@login_required
def generate_document(request, template_id):
    """
    Генерирует заполненный документ на основе шаблона и данных пользователя
    """
    template_obj = get_object_or_404(DocumentTemplate, id=template_id)

    try:
        dogovor = Dogovor.objects.get(user=request.user)
    except Dogovor.DoesNotExist:
        dogovor = None

    try:
        pril = Prilojenie12.objects.get(user=request.user)
    except Prilojenie12.DoesNotExist:
        pril = None

    try:
        list_kontrol = ListKontrol.objects.get(user=request.user)
    except ListKontrol.DoesNotExist:
        list_kontrol = None

    def format_date(date_value):
        """Для DateField: дата в формате DD.MM.YY"""
        if date_value and isinstance(date_value, (datetime, date)):
            return date_value.strftime('%d.%m.%y')
        return ''

    def reverse_date_str(date_str):
        """Для текстовых полей: строку YYYY-MM-DD -> DD.MM.YY"""
        if date_str and isinstance(date_str, str) and '-' in date_str:
            parts = date_str.split('-')
            if len(parts) == 3:
                y, m, d = parts
                return f"{d}.{m}.{y[2:]}"
        return date_str or ''

    # Собираем контекст
    context = {
        # Данные пользователя
        'username': request.user.username,
        'email': request.user.email,
        'first_name': request.user.first_name,
        'last_name': request.user.last_name,

        # Данные из Dogovor
        'org': dogovor.org if dogovor else '',
        'adress': dogovor.adress if dogovor else '',
        'smart': dogovor.smart if dogovor else '',
        'rec': dogovor.rec if dogovor else '',
        'rycov': dogovor.rycov if dogovor else '',

        # Данные из Prilojenie12
        'modul': pril.module.name if pril and pril.module else '',  # если module – ForeignKey
        'start': format_date(pril.start) if pril else '',
        'final': format_date(pril.final) if pril else '',
        'akd': pril.akd if pril else '',
        'fio_stud': pril.fio_stud if pril else '',
        'date_birth': format_date(pril.date_birth) if pril else '',
        'fioruk': pril.fioruk if pril else '',
        'num_ruk': pril.num_ruk if pril else '',
        'fioprofruk': pril.fioprofruk if pril else '',
        'doljnost_profruk': pril.doljnost_profruk if pril else '',
        'numprofruk': pril.numprofruk if pril else '',
        'org_pril': pril.org if pril else '',
        'fiootv': pril.fiootv if pril else '',
        'doljotv': pril.doljotv if pril else '',
        'numberotv': pril.numberotv if pril else '',
        'addres': pril.addres if pril else '',
        'namepomech': pril.namepomech if pril else '',

        # Данные из ListKontrol
        'gru': list_kontrol.gru if list_kontrol else '',
        # Применяем reverse_date_str для строковых дат
        'prohod_pract': reverse_date_str(list_kontrol.prohod_pract) if list_kontrol and list_kontrol.prohod_pract else '',
        'date': reverse_date_str(list_kontrol.date) if list_kontrol and list_kontrol.date else '',
        'fio_ruk': list_kontrol.fio_ruk if list_kontrol else '',
        'org_list': list_kontrol.org if list_kontrol else '',
        'ryk_p': list_kontrol.ryk_p if list_kontrol else '',
        'fioprisut': list_kontrol.fioprisut if list_kontrol else '',
        'fio_ots': list_kontrol.fio_ots if list_kontrol else '',
        'prichina': list_kontrol.prichina if list_kontrol else '',

        # Направление (связь через direction)
        'kod': list_kontrol.direction.name_naprav if list_kontrol and list_kontrol.direction else '',
        'name_naprav': list_kontrol.direction.kod if list_kontrol and list_kontrol.direction else '',
        'direction_kod': list_kontrol.direction.name_naprav if list_kontrol and list_kontrol.direction else '',
        'direction_name': list_kontrol.direction.kod if list_kontrol and list_kontrol.direction else '',
    }

    doc = DocxTemplate(template_obj.template_file.path)
    doc.render(context)

    doc_io = BytesIO()
    doc.save(doc_io)
    doc_io.seek(0)

    filename = f"{template_obj.title}_{request.user.username}_{context.get('fio_stud', 'document')}.docx"
    filename = filename.replace(' ', '_')

    response = HttpResponse(
        doc_io.getvalue(),
        content_type='application/vnd.openxmlformats-officedocument.wordprocessingml.document'
    )
    response['Content-Disposition'] = f'attachment; filename="{filename}"'
    return response