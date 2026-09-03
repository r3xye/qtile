from libqtile.widget import base 

class Test(base._TextBox):
    # Описываем настройки по умолчанию
    defaults = [
        (
            "text",         # Имя переменной
            "Hello Qtile",  # Значение по умолчанию
            "Text to Display" # Описание
        ),
    ]

    def __init__(self, **config):
        # 1. Сначала инициализируем базовый класс БЕЗ передачи строки.
        # Это предотвратит ошибку отсутствия атрибутов во внутренностях Qtile.
        super().__init__(**config)
        
        # 2. Теперь подмешиваем наш массив defaults
        self.add_defaults(Test.defaults)
        
        # 3. Если при создании виджета текст НЕ передали, 
        # берем значение из defaults (то есть "Hello Qtile")
        if not self.text:
            self.text = self.default_text  # Внутреннее имя для дефолтного text

    def draw(self):
        # Закрашиваем фон в красный
        self.drawer.clear("#ff0000")
        
        # Передаем отрисовку тексту
        super().draw()
