<?php
// app/Services/DocumentGeneratorService.php

namespace App\Services;

use PhpOffice\PhpWord\PhpWord;
use PhpOffice\PhpWord\IOFactory;
use PhpOffice\PhpWord\SimpleType\Jc;
use PhpOffice\PhpWord\Style\Font;

class DocumentGeneratorService
{
    /**
     * Генерация документа с данными персонажа
     */
    public function generateCharacterDocument($character, $template = 'default')
    {
        // Создаём новый документ
        $phpWord = new PhpWord();
        
        // Настройки документа
        $section = $phpWord->addSection([
            'pageSize' => 'A4',
            'pageOrientation' => 'portrait'
        ]);
        
        // Заголовок
        $section->addTitle('Лист персонажа', 1);
        $section->addTextBreak(1);
        
        // Основная информация
        $table = $section->addTable(['borderSize' => 1, 'borderColor' => '000000']);
        
        // Имя персонажа
        $table->addRow();
        $table->addCell(3000)->addText('Имя персонажа:', ['bold' => true]);
        $table->addCell(9000)->addText($character->name);
        
        // Раса
        $table->addRow();
        $table->addCell(3000)->addText('Раса:', ['bold' => true]);
        $table->addCell(9000)->addText($character->race->name ?? 'Не указана');
        
        // Класс
        $table->addRow();
        $table->addCell(3000)->addText('Класс:', ['bold' => true]);
        $table->addCell(9000)->addText($character->class->name ?? 'Не указан');
        
        // Уровень
        $table->addRow();
        $table->addCell(3000)->addText('Уровень:', ['bold' => true]);
        $table->addCell(9000)->addText($character->level);
        
        // Опыт
        $table->addRow();
        $table->addCell(3000)->addText('Опыт:', ['bold' => true]);
        $table->addCell(9000)->addText($character->experience);
        
        // Золото
        $table->addRow();
        $table->addCell(3000)->addText('Золото:', ['bold' => true]);
        $table->addCell(9000)->addText(number_format($character->gold) . ' 💰');
        
        $section->addTextBreak(1);
        
        // Характеристики
        $section->addTitle('Характеристики', 2);
        
        $statsTable = $section->addTable(['borderSize' => 1]);
        
        $statsTable->addRow();
        $statsTable->addCell(3000)->addText('💪 Сила:', ['bold' => true]);
        $statsTable->addCell(3000)->addText($character->strength);
        $statsTable->addCell(3000)->addText('🏃 Ловкость:', ['bold' => true]);
        $statsTable->addCell(3000)->addText($character->agility);
        
        $statsTable->addRow();
        $statsTable->addCell(3000)->addText('🧠 Интеллект:', ['bold' => true]);
        $statsTable->addCell(3000)->addText($character->intelligence);
        $statsTable->addCell(3000)->addText('❤️ Здоровье:', ['bold' => true]);
        $statsTable->addCell(3000)->addText($character->health_current . '/' . $character->health_max);
        
        $statsTable->addRow();
        $statsTable->addCell(3000)->addText('💙 Мана:', ['bold' => true]);
        $statsTable->addCell(9000)->addText($character->mana_current . '/' . $character->mana_max);
        
        $section->addTextBreak(1);
        
        // Способности
        if ($character->abilities && $character->abilities->count() > 0) {
            $section->addTitle('Способности', 2);
            
            $abilitiesTable = $section->addTable(['borderSize' => 1]);
            
            foreach ($character->abilities as $ability) {
                $abilitiesTable->addRow();
                $abilitiesTable->addCell(3000)->addText($ability->name, ['bold' => true]);
                $abilitiesTable->addCell(9000)->addText($ability->description ?? 'Нет описания');
            }
        }
        
        $section->addTextBreak(1);
        
        // Инвентарь
        if ($character->inventory && $character->inventory->count() > 0) {
            $section->addTitle('Инвентарь', 2);
            
            $inventoryTable = $section->addTable(['borderSize' => 1]);
            
            // Заголовки
            $inventoryTable->addRow();
            $inventoryTable->addCell(3000)->addText('Предмет', ['bold' => true]);
            $inventoryTable->addCell(2000)->addText('Кол-во', ['bold' => true]);
            $inventoryTable->addCell(3000)->addText('Тип', ['bold' => true]);
            $inventoryTable->addCell(4000)->addText('Статус', ['bold' => true]);
            
            foreach ($character->inventory as $item) {
                $inventoryTable->addRow();
                $inventoryTable->addCell(3000)->addText($item->item->name ?? '?');
                $inventoryTable->addCell(2000)->addText($item->quantity);
                $inventoryTable->addCell(3000)->addText($item->item->item_type ?? '?');
                $inventoryTable->addCell(4000)->addText($item->is_equipped ? 'Экипировано' : 'В инвентаре');
            }
        }
        
        // Подвал
        $section->addTextBreak(2);
        $section->addText(
            'Сгенерировано: ' . now()->format('d.m.Y H:i:s'),
            ['italic' => true, 'size' => 10]
        );
        
        // Сохраняем в память
        $tempFile = tempnam(sys_get_temp_dir(), 'character_');
        $phpWord->save($tempFile, 'Word2007');
        
        $content = file_get_contents($tempFile);
        unlink($tempFile);
        
        return $content;
    }
}