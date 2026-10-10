from __future__ import annotations

from dataclasses import dataclass
from datetime import date
from pathlib import Path
from urllib.parse import quote


ROOT = Path(__file__).resolve().parents[1]
REPORTS_DIR = ROOT / "reports"
REPORT_STEM = "hotel_rezervasyon_raporu"
REPORT_MD = REPORTS_DIR / f"{REPORT_STEM}.md"
REPORT_TEX = REPORTS_DIR / f"{REPORT_STEM}.tex"


@dataclass(frozen=True)
class CodeSection:
    path: str
    language: str
    title: str
    role: str
    explanation: str


CODE_SECTIONS = [
    CodeSection(
        path="pubspec.yaml",
        language="yaml",
        title="Proje bağımlılıkları ve asset tanımları",
        role=(
            "Bu dosya Flutter projesinin paket bağımlılıklarını, SDK aralığını "
            "ve uygulamada kullanılacak görsel klasörlerini tanımlar."
        ),
        explanation=(
            "Rapor açısından bu dosya önemlidir; çünkü projenin yalnızca görsel "
            "olarak değil, teknik olarak da hangi çerçeve ve paketler üstüne "
            "kurulduğunu burada görüyoruz. `provider` durum yönetimi için, "
            "`shared_preferences` ise rezervasyonları yerel bellekte tutmak için "
            "kullanılmıştır."
        ),
    ),
    CodeSection(
        path="lib/main.dart",
        language="dart",
        title="Uygulamanın giriş noktası",
        role=(
            "Bu dosya uygulamanın başlangıç dosyasıdır. `main()` fonksiyonu "
            "çalışır ve `MyApp` widget'ını ekrana basar."
        ),
        explanation=(
            "Kod çok kısa tutulmuştur. Bu tercih iyi bir ayrım sağlar; başlangıç "
            "mantığı burada kalır, asıl uygulama kurulumu ise `app/app.dart` "
            "içine taşınır."
        ),
    ),
    CodeSection(
        path="lib/app/app.dart",
        language="dart",
        title="Uygulama kurulumu ve Provider bağlama",
        role=(
            "Bu dosya `MaterialApp` ağacını oluşturur, temayı uygular ve "
            "`HotelAppState` nesnesini `ChangeNotifierProvider` ile tüm "
            "ekranlara açar."
        ),
        explanation=(
            "Buradaki yapı Flutter projelerinde sık görülen temiz bir kurulum "
            "örneğidir. State nesnesinin başlangıçta `load()` çağrısı ile "
            "hazırlanması, daha uygulama açılırken önceki rezervasyonların "
            "ekrana taşınmasına imkân verir."
        ),
    ),
    CodeSection(
        path="lib/app/theme.dart",
        language="dart",
        title="Tema, renk sistemi ve ortak görünüm kararları",
        role=(
            "Bu dosya uygulamanın bütün görsel dilini belirler. Renk paleti, "
            "yazı stilleri, kart biçimleri, buton temaları, input alanları ve "
            "navigasyon görünümü burada merkezi biçimde tanımlanır."
        ),
        explanation=(
            "Tema dosyası ayrı tutulduğu için arayüz kararları tek noktadan "
            "kontrol edilebilir hâle gelmiştir. Bu, ders projesi için önemli bir "
            "artıdır; çünkü uygulama ileride büyüse bile farklı ekranlar arasında "
            "stil tutarlılığı korunur."
        ),
    ),
    CodeSection(
        path="lib/data/demo_content.dart",
        language="dart",
        title="Demo otel ve oda verileri",
        role=(
            "Bu dosya dış servis kullanılmadan çalışan örnek veri setini içerir. "
            "Otel listeleri, oda seçenekleri, etiketler, fiyatlar ve görsel "
            "yolları burada sabit veri olarak tanımlanmıştır."
        ),
        explanation=(
            "Gerçek bir arka uç kullanılmadığı için ders kapsamında ihtiyaç "
            "duyulan veri akışı bu sabit listeler üzerinden çözülmüştür. Böylece "
            "arayüz, filtreleme ve rezervasyon mantığı veri kaynağına bağlı "
            "kalmadan gösterilebilir."
        ),
    ),
    CodeSection(
        path="lib/models/hotel_models.dart",
        language="dart",
        title="Veri modelleri ve serileştirme mantığı",
        role=(
            "Bu dosyada otel, oda ve rezervasyon için kullanılan veri sınıfları "
            "yer alır. `Reservation` modeli ayrıca JSON dönüşümü, gece hesabı ve "
            "toplam ücret hesabı gibi iş kurallarını da taşır."
        ),
        explanation=(
            "Model katmanının ayrı tutulması kodun okunmasını kolaylaştırır. "
            "Özellikle `fromJson()` içindeki eski veri biçimleriyle uyumluluk "
            "sağlayan yapı, yerel depolamadaki önceki kayıtların boşa gitmemesi "
            "için düşünülmüş pratik bir çözümdür."
        ),
    ),
    CodeSection(
        path="lib/state/hotel_app_state.dart",
        language="dart",
        title="Merkezi uygulama durumu ve veri kalıcılığı",
        role=(
            "Bu dosya seçili oteli, seçili odayı, rezervasyon listesini ve yükleme "
            "kaydetme işlemlerini yönetir. Uygulamanın mantıksal merkezi burasıdır."
        ),
        explanation=(
            "`ChangeNotifier` yapısı sayesinde arayüz tarafı, state değiştiğinde "
            "kendini günceller. Ayrıca `SharedPreferences` ile kayıtların saklanması, "
            "uygulamayı kapatıp açınca rezervasyonların yeniden gösterilmesini sağlar."
        ),
    ),
    CodeSection(
        path="lib/screens/hotel_shell.dart",
        language="dart",
        title="Ana kabuk, menü yapısı ve responsive navigasyon",
        role=(
            "Bu ekran uygulamanın dış kabuğunu oluşturur. Geniş ekranda sol menü, "
            "dar ekranda alt gezinme çubuğu kullanır ve ilgili iç ekranı gösterir."
        ),
        explanation=(
            "Buradaki yapı mobil ve geniş ekran uyumunu göstermek açısından "
            "değerlidir. `AnimatedSwitcher` ile geçişlerin yumuşatılması ve seçili "
            "otel bilgisinin menü kartında özetlenmesi kullanıcı deneyimini artırır."
        ),
    ),
    CodeSection(
        path="lib/screens/hotels_screen.dart",
        language="dart",
        title="Otel listeleme, arama ve filtreleme ekranı",
        role=(
            "Bu dosya otellerin kullanıcıya listelendiği ana ekranı kurar. "
            "Arama kutusu, puan filtresi, semt filtresi, özellik seçimi ve "
            "otel kartları burada oluşturulur."
        ),
        explanation=(
            "Listeleme ekranı projedeki ilk kullanıcı temasını temsil eder. "
            "Arama sorgusunun doğrudan veri kümesine uygulanması ve filtrelerin "
            "modal alt sayfa üzerinden verilmesi, mobil arayüzlerde sık kullanılan "
            "pratik bir yaklaşımı göstermektedir."
        ),
    ),
    CodeSection(
        path="lib/screens/booking_screen.dart",
        language="dart",
        title="Rezervasyon formu, tarih seçimi ve fiyat özeti",
        role=(
            "Projenin en yoğun ekranı burasıdır. Oda varyantı seçimi, tarih "
            "aralığı belirleme, misafir sayısı değiştirme, ek hizmet seçme, "
            "form doğrulama ve toplam ücret hesabı aynı akış içinde yürütülür."
        ),
        explanation=(
            "Bu dosya ders açısından en güçlü bölümdür; çünkü hem kullanıcı "
            "arayüzünü hem de iş kuralı mantığını birlikte taşır. `showDateRangePicker`, "
            "form validasyonu, `LayoutBuilder` ile duyarlı yerleşim ve ek hizmet "
            "hesaplamaları aynı ekranda bir araya getirilmiştir."
        ),
    ),
    CodeSection(
        path="lib/screens/reservations_screen.dart",
        language="dart",
        title="Yaklaşan ve geçmiş rezervasyonları gösteren ekran",
        role=(
            "Bu dosya daha önce oluşturulmuş kayıtların kullanıcıya iki ayrı "
            "kategori hâlinde sunulmasını sağlar. `SegmentedButton` ile yaklaşan "
            "ve geçmiş kayıtlar arasında geçiş yapılır."
        ),
        explanation=(
            "Burada asıl dikkat çeken nokta, veri listesinin doğrudan ham hâlde "
            "değil, state katmanında ayrıştırılmış listeler üzerinden okunmasıdır. "
            "Böylece ekran tarafında daha temiz ve sade bir kod yapısı elde edilmiştir."
        ),
    ),
    CodeSection(
        path="lib/utils/formatters.dart",
        language="dart",
        title="Para ve tarih biçimlendirme yardımcıları",
        role=(
            "Bu dosya ekranda tekrar tekrar kullanılan para ve tarih gösterimlerini "
            "tek bir yerde toplar."
        ),
        explanation=(
            "Küçük görünse de proje bütünlüğü için yararlıdır. Biçimlendirme "
            "fonksiyonlarının ayrı tutulması, aynı dönüşümün farklı ekranlarda "
            "kopyalanmasını engeller."
        ),
    ),
    CodeSection(
        path="lib/widgets/hotel_widgets.dart",
        language="dart",
        title="Tekrar kullanılabilir ortak widget bileşenleri",
        role=(
            "Bu dosya kart, başlık, etiket, metrik kutusu ve görsel kahraman alanı "
            "gibi birçok ortak arayüz parçasını içerir."
        ),
        explanation=(
            "Tekrarlı arayüz kodunun ortak widget'lara ayrılması, hem okunabilirliği "
            "yükseltmiş hem de ekran dosyalarının sadece kendi iş mantıklarına "
            "odaklanmasını sağlamıştır."
        ),
    ),
    CodeSection(
        path="test/widget_test.dart",
        language="dart",
        title="Widget testleri ve temel senaryolar",
        role=(
            "Bu dosya uygulamanın bazı temel akışlarını test eder. Menülerin "
            "görünmesi, boş rezervasyon ekranı, otel seçimi, doğrulama mesajı "
            "ve filtre davranışı burada kontrol edilir."
        ),
        explanation=(
            "Ders projelerinde test bölümü çoğu zaman eksik bırakılır. Bu projede "
            "en azından temel kullanıcı senaryolarının otomatik olarak doğrulanması, "
            "uygulamanın daha ciddi ve kontrollü hazırlandığını gösterir."
        ),
    ),
]


PROJECT_TREE = """hotel_rezervasyon/
├── assets/
│   └── images/
│       ├── deluxe.jpg
│       ├── standard.jpg
│       ├── suite.jpg
│       └── stock/
│           ├── breakfast.jpg
│           ├── lobby.jpg
│           ├── pool.jpg
│           └── room.jpg
├── lib/
│   ├── app/
│   ├── data/
│   ├── models/
│   ├── screens/
│   ├── state/
│   ├── utils/
│   ├── widgets/
│   └── main.dart
├── test/
│   └── widget_test.dart
└── pubspec.yaml
"""


def read_text(relative_path: str) -> str:
    return (ROOT / relative_path).read_text(encoding="utf-8")


def count_lines(relative_path: str) -> int:
    return len(read_text(relative_path).splitlines())


def escape_tex(text: str) -> str:
    replacements = {
        "\\": r"\textbackslash{}",
        "&": r"\&",
        "%": r"\%",
        "$": r"\$",
        "#": r"\#",
        "_": r"\_",
        "{": r"\{",
        "}": r"\}",
        "~": r"\textasciitilde{}",
        "^": r"\textasciicircum{}",
    }
    return "".join(replacements.get(char, char) for char in text)


def markdown_code_block(language: str, code: str) -> str:
    return f"```{language}\n{code.rstrip()}\n```"


def tex_code_block(code: str) -> str:
    return (
        "\\begin{codeblock}\n"
        f"{code.rstrip()}\n"
        "\\end{codeblock}\n"
    )


def report_image_paths() -> list[Path]:
    allowed_suffixes = {".png", ".jpg", ".jpeg", ".webp"}
    return sorted(
        path for path in REPORTS_DIR.iterdir()
        if path.is_file() and path.suffix.lower() in allowed_suffixes
    )


def chunked(items: list[Path], size: int) -> list[list[Path]]:
    return [items[index:index + size] for index in range(0, len(items), size)]


def build_intro_sections() -> list[dict[str, object]]:
    return [
        {
            "title": "Projenin Özeti",
            "paragraphs": [
                (
                    "Bu projeyi üniversitedeki final projemiz olarak hazırladık. Amacımız, "
                    "bir otel rezervasyon uygulamasının kullanıcı tarafında nasıl görüneceğini "
                    "ve nasıl işleyeceğini daha anlaşılır bir şekilde ortaya koymaktı. "
                    "Kullanıcı uygulamaya girdiğinde otellere bakabiliyor, oda seçebiliyor, "
                    "tarih belirleyebiliyor ve rezervasyon sürecini baştan sona takip edebiliyor."
                ),
                (
                    "Projeyi geliştirirken sadece birkaç ekran göstermek istemedik. Daha çok "
                    "gerçek bir uygulama hissi vermeye çalıştık. Bu yüzden önce arayüzü Figma "
                    "üzerinde tasarladık, ekranların nasıl görüneceğini netleştirdik ve daha "
                    "sonra bu tasarımı Flutter tarafına aktardık. Ardından uygulamanın gerçekten "
                    "çalışması için butonlar, menü geçişleri ve veri düzeni gibi arka plan "
                    "kısımlarını ekledik. Böylece ortaya hem göze daha yakın gelen hem de kullanım "
                    "akışı daha derli toplu olan bir çalışma çıktı."
                ),
            ],
        },
        {
            "title": "Projenin Amacı ve Kapsamı",
            "paragraphs": [
                (
                    "Bu projede temel hedefimiz, otel rezervasyonu fikrini öğrenci projesi "
                    "ölçeğinde anlaşılır ve düzenli bir şekilde ortaya koymaktı. Önce uygulamanın "
                    "arayüz tarafını Figma üzerinde düşündük, ekranların nasıl görüneceğini planladık "
                    "ve kullanıcı akışını kurduk. Daha sonra bu tasarımı Flutter içine taşıyarak "
                    "çalışan bir mobil uygulama hâline getirdik."
                ),
                (
                    "İlerleyen aşamada uygulamanın sadece görünüşten ibaret kalmaması için "
                    "arka planda çalışacak mantığı da ekledik. Yani önce kullanıcıya görünen "
                    "bölümü hazırladık, sonra bu ekranların gerçekten çalışmasını sağlayan backend "
                    "tarafını ekledik. Burada butonların işlev kazanması, menüler arası geçişlerin "
                    "çalışması ve verilerin uygun şekilde ayarlanması gibi kısımlar sonradan yazıldı. "
                    "Bu yüzden proje hem tasarım yönünü hem de uygulamanın işleyen tarafını birlikte "
                    "anlatan bir final çalışmasına dönüştü."
                ),
            ],
        },
        {
            "title": "Genel Uygulama Akışı",
            "paragraphs": [
                (
                    "Uygulamanın genel akışını olabildiğince sade kurduk. Kullanıcı önce otelleri "
                    "görüyor, ardından ilgisini çeken bir oteli seçiyor. Sonraki adımda oda "
                    "seçimi yapıyor, kalacağı tarihleri belirliyor ve kendine uygun rezervasyon "
                    "bilgilerini dolduruyor."
                ),
                (
                    "Biz burada kullanıcıyı gereksiz karmaşaya sokmamaya dikkat ettik. Adımlar "
                    "birbirini doğal şekilde takip ediyor. Rezervasyon tamamlandıktan sonra da "
                    "yapılan işlem kaybolmuyor; kullanıcı daha sonra kendi kayıtlarını tekrar "
                    "görebiliyor. Bu da projeyi sadece ekran gösteren bir çalışma olmaktan çıkarıp "
                    "daha tamamlanmış bir uygulama örneğine yaklaştırdı."
                ),
            ],
            "numbered": [
                "Kullanıcı oteller ekranına gelir ve listeyi inceler.",
                "Arama kutusu ve filtre alt sayfası ile uygun tesisleri daraltır.",
                "Bir otel kartına tıklayarak rezervasyon ekranına geçer.",
                "Seçili otelin oda varyantları arasından uygun olanı belirler.",
                "Tarih aralığını, misafir sayısını ve ek hizmetleri seçer.",
                "Form alanlarını doldurup rezervasyonu oluşturur.",
                "Kaydı rezervasyonlar ekranında yaklaşan veya geçmiş listesinde görür.",
            ],
        },
        {
            "title": "Proje Dizin Yapısı",
            "paragraphs": [
                (
                    "Projeyi geliştirirken dosyaları da karışmayacak şekilde ayırmaya çalıştık. "
                    "Böylece hangi kısmın ekranlarla, hangi kısmın veriyle ya da ortak bileşenlerle "
                    "ilgili olduğu daha rahat anlaşılabilir oldu. Bu düzen bize rapor yazarken ve "
                    "projenin hangi bölümde ne yaptığını anlatırken de kolaylık sağladı."
                ),
            ],
            "code": PROJECT_TREE.rstrip(),
            "code_language": "text",
        },
        {
            "title": "Projeyi Nasıl İlerlettik",
            "paragraphs": [
                (
                    "Projeyi geliştirirken önce kullanıcıda ilk izlenimi oluşturacak arayüzü "
                    "hazırladık. Bu aşamada Figma üzerinde hangi sayfaların olacağına, kullanıcı "
                    "nerede ne göreceğine ve rezervasyon sürecinin nasıl ilerleyeceğine karar verdik. "
                    "Daha sonra bu taslağı Flutter içinde parça parça kurarak çalışan ekranlara "
                    "dönüştürdük."
                ),
                (
                    "Arayüz oturduktan sonra uygulamanın arka tarafta gerçekten bir mantıkla "
                    "çalışması için gerekli bölümleri ekledik. Yani kullanıcı bir tuşa bastığında "
                    "doğru işlemin olması, menüler arasında geçişlerin düzgün çalışması, seçimlerden "
                    "sonra uygun verilerin ekrana gelmesi ve rezervasyon tamamlandığında bunun "
                    "kaybolmaması gibi backend tarafını ilgilendiren kısımlar sonradan geliştirilerek "
                    "projeye eklendi."
                ),
            ],
        },
        {
            "title": "Kayıtların Saklanması",
            "paragraphs": [
                (
                    "Bizim için önemli olan noktalardan biri de kullanıcının yaptığı işlemin "
                    "uygulama içinde kaybolmamasıydı. Bu yüzden otel seçimi, oda bilgisi ve "
                    "oluşturulan rezervasyon gibi verilerin uygulama içinde düzenli şekilde "
                    "ilerlemesine dikkat ettik."
                ),
                (
                    "Ayrıca yapılan rezervasyonların daha sonra tekrar görülebilmesi projeyi daha "
                    "gerçekçi gösterdi. Kullanıcı uygulamayı kapatıp açsa bile önceki kayıtları "
                    "yeniden görebiliyor. Bu ayrıntı, final projesi olarak sunarken uygulamanın "
                    "daha tamamlanmış görünmesine katkı sağladı."
                ),
            ],
        },
        {
            "title": "Kullanıcı Deneyimi Tarafı",
            "paragraphs": [
                (
                    "Kullanıcı uygulamayı kullanırken zorlanmasın diye arama ve filtreleme "
                    "kısımlarını ekledik. Böylece listede kaybolmadan daha uygun otellere daha "
                    "kolay ulaşılabiliyor. Aynı şekilde rezervasyon formunda da kullanıcıdan "
                    "istenen bilgiler olabildiğince anlaşılır şekilde verildi."
                ),
                (
                    "Burada amacımız teknik olarak karmaşık görünmekten çok, kullanıcı açısından "
                    "akıcı bir deneyim sunmaktı. Yani kişi neyi, neden girdiğini anlayabilsin; "
                    "uygulama da gerekli yerlerde onu yönlendirsin istedik. Bu yaklaşım projeyi "
                    "daha insani ve daha kullanılabilir bir noktaya taşıdı."
                ),
            ],
        },
        {
            "title": "Arayüz Tarafı",
            "paragraphs": [
                (
                    "Arayüz tarafında sade ama düzenli bir görünüm oluşturmaya çalıştık. Çok ağır "
                    "ya da karışık bir tasarım yerine, öğrencilerin geliştirdiği bir final projesine "
                    "yakışacak şekilde temiz, anlaşılır ve sunumda rahat gösterilebilecek bir yapı "
                    "kurduk. Bu görsel düzeni önce Figma üzerinde çizdik, sonra Flutter tarafında "
                    "aynı hissi verecek şekilde uygulamaya aktardık."
                ),
                (
                    "Ekranların farklı boyutlarda da düzgün görünmesine dikkat ettik. Çünkü projeyi "
                    "sadece kod olarak değil, görsel olarak da sunacağımız için uygulamanın farklı "
                    "ekranlarda bozulmadan çalışması bizim için önemliydi. Bu yüzden arayüzü önce "
                    "Figma tarafında netleştirip sonra Flutter içinde buna uygun şekilde düzenledik. "
                    "Ardından arka tarafta buton işlevleri, geçişler ve veri hareketleri eklenince "
                    "uygulama sadece güzel görünen değil, aynı zamanda çalışan bir yapıya dönüştü."
                ),
            ],
        },
    ]


def render_markdown(intro_sections: list[dict[str, object]]) -> str:
    lines: list[str] = [
        "# Hotel Reservation Flutter Projesi Raporu",
        "",
    ]

    for section in intro_sections:
        lines.append(f"## {section['title']}")
        lines.append("")
        for paragraph in section.get("paragraphs", []):
            lines.append(str(paragraph))
            lines.append("")

        if "numbered" in section:
            for item in section["numbered"]:
                lines.append(f"1. {item}")
            lines.append("")

        if "bullets" in section:
            for item in section["bullets"]:
                lines.append(f"- {item}")
            lines.append("")

        if "subheading" in section:
            lines.append(f"### {section['subheading']}")
            lines.append("")

        if "sub_bullets" in section:
            for item in section["sub_bullets"]:
                lines.append(f"- {item}")
            lines.append("")

        if "code" in section:
            lines.append(markdown_code_block(section.get("code_language", "text"), str(section["code"])))
            lines.append("")

    lines.extend(
        [
            "## Kod Bölümleri",
            "",
            "Aşağıdaki bölümde projeyi oluşturan temel dosyalar tek tek verilmiş, her dosyanın ne işe yaradığı anlatılmış ve ilgili kod içerikleri rapora eklenmiştir.",
            "",
        ]
    )

    for index, section in enumerate(CODE_SECTIONS, start=1):
        code = read_text(section.path)
        lines.extend(
            [
                f"### {index}. {section.path} - {section.title}",
                "",
                f"**Dosyanın görevi:** {section.role}",
                "",
                f"**Satır sayısı:** {count_lines(section.path)}",
                "",
                markdown_code_block(section.language, code),
                "",
                f"**Açıklama:** {section.explanation}",
                "",
            ]
        )

    images = report_image_paths()
    if images:
        lines.extend(
            [
                "## Uygulama Ekran Görselleri",
                "",
                "Aşağıda uygulamadan alınan ekran görüntüleri ikili yerleşim ile sunulmuştur.",
                "",
                "<table>",
            ]
        )

        for image_pair in chunked(images, 2):
            lines.append("<tr>")
            for image in image_pair:
                lines.append(
                    f'<td width="50%"><img src="{quote(image.name)}" alt="{image.stem}" width="100%"></td>'
                )
            if len(image_pair) == 1:
                lines.append('<td width="50%"></td>')
            lines.append("</tr>")

        lines.extend(
            [
                "</table>",
                "",
            ]
        )

    return "\n".join(lines).rstrip() + "\n"


def render_tex(intro_sections: list[dict[str, object]]) -> str:
    lines: list[str] = [
        r"\documentclass[11pt,a4paper]{article}",
        r"\usepackage[a4paper,margin=2cm]{geometry}",
        r"\usepackage{fontspec}",
        r"\usepackage{polyglossia}",
        r"\setmainlanguage{turkish}",
        r"\setmainfont{Liberation Serif}",
        r"\setsansfont{Liberation Sans}",
        r"\setmonofont{Source Code Pro}",
        r"\usepackage{graphicx}",
        r"\usepackage{xcolor}",
        r"\usepackage{hyperref}",
        r"\usepackage{enumitem}",
        r"\usepackage{titlesec}",
        r"\usepackage{listings}",
        r"\usepackage{longtable}",
        r"\usepackage{booktabs}",
        r"\hypersetup{colorlinks=true,linkcolor=black,urlcolor=blue}",
        r"\setlist[itemize]{nosep,leftmargin=1.8em}",
        r"\setlist[enumerate]{nosep,leftmargin=1.8em}",
        r"\definecolor{panelborder}{HTML}{D9DEE3}",
        r"\lstdefinestyle{reportcode}{basicstyle=\ttfamily\footnotesize,breaklines=true,breakatwhitespace=false,columns=fullflexible,keepspaces=true,frame=single,rulecolor=\color{panelborder},numbers=left,numbersep=8pt,showstringspaces=false,literate={ı}{{\i}}1 {İ}{{\.I}}1 {ğ}{{\u g}}1 {Ğ}{{\u G}}1 {ş}{{\c s}}1 {Ş}{{\c S}}1 {ö}{{\"o}}1 {Ö}{{\"O}}1 {ü}{{\"u}}1 {Ü}{{\"U}}1 {ç}{{\c c}}1 {Ç}{{\c C}}1 {₺}{{{\fontspec{Liberation Serif}₺}}}1}",
        r"\lstnewenvironment{codeblock}{\lstset{style=reportcode}}{}",
        r"\titleformat{\section}{\Large\bfseries}{}{0pt}{}",
        r"\titleformat{\subsection}{\large\bfseries}{}{0pt}{}",
        r"\begin{document}",
        r"\sloppy",
        r"\tableofcontents",
        r"\clearpage",
    ]

    for section in intro_sections:
        lines.append(rf"\section{{{escape_tex(str(section['title']))}}}")
        for paragraph in section.get("paragraphs", []):
            lines.append(escape_tex(str(paragraph)))
            lines.append("")

        if "numbered" in section:
            lines.append(r"\begin{enumerate}")
            for item in section["numbered"]:
                lines.append(rf"\item {escape_tex(str(item))}")
            lines.append(r"\end{enumerate}")
            lines.append("")

        if "bullets" in section:
            lines.append(r"\begin{itemize}")
            for item in section["bullets"]:
                lines.append(rf"\item {escape_tex(str(item))}")
            lines.append(r"\end{itemize}")
            lines.append("")

        if "subheading" in section:
            lines.append(rf"\subsection*{{{escape_tex(str(section['subheading']))}}}")

        if "sub_bullets" in section:
            lines.append(r"\begin{itemize}")
            for item in section["sub_bullets"]:
                lines.append(rf"\item {escape_tex(str(item))}")
            lines.append(r"\end{itemize}")
            lines.append("")

        if "code" in section:
            lines.append(tex_code_block(str(section["code"])))

    lines.append(r"\clearpage")
    lines.append(r"\section{Kod Bölümleri}")
    lines.append(
        escape_tex(
            "Aşağıdaki bölümde projeyi oluşturan temel dosyalar tek tek verilmiş, "
            "her dosyanın ne işe yaradığı anlatılmış ve ilgili kod içerikleri rapora eklenmiştir."
        )
    )
    lines.append("")

    for index, section in enumerate(CODE_SECTIONS, start=1):
        code = read_text(section.path)
        lines.append(r"\clearpage")
        lines.append(
            rf"\subsection{{{escape_tex(f'{index}. {section.path} - {section.title}')}}}"
        )
        lines.append(rf"\textbf{{Dosyanın görevi:}} {escape_tex(section.role)}")
        lines.append("")
        lines.append(
            rf"\textbf{{Satır sayısı:}} {escape_tex(str(count_lines(section.path)))}"
        )
        lines.append("")
        lines.append(tex_code_block(code))
        lines.append(rf"\textbf{{Açıklama:}} {escape_tex(section.explanation)}")
        lines.append("")

    images = report_image_paths()
    if images:
        lines.append(r"\clearpage")
        lines.append(r"\section{Uygulama Ekran Görselleri}")
        lines.append(
            escape_tex(
                "Aşağıda uygulamadan alınan ekran görüntüleri ikili yerleşim ile sunulmuştur."
            )
        )
        lines.append("")

        for image_pair in chunked(images, 2):
            lines.append(r"\begin{center}")
            for pair_index, image in enumerate(image_pair):
                if pair_index > 0:
                    lines.append(r"\hfill")
                lines.append(r"\begin{minipage}[t]{0.48\textwidth}")
                lines.append(r"\centering")
                lines.append(
                    r"\includegraphics[width=\linewidth,height=0.34\textheight,keepaspectratio]{"
                    + r"\detokenize{"
                    + image.relative_to(ROOT).as_posix()
                    + r"}}"
                )
                lines.append(r"\end{minipage}")
            if len(image_pair) == 1:
                lines.append(r"\hfill\begin{minipage}[t]{0.48\textwidth}\mbox{}\end{minipage}")
            lines.append(r"\end{center}")
            lines.append(r"\vspace{0.8cm}")

    lines.append(r"\end{document}")
    return "\n".join(lines).rstrip() + "\n"


def main() -> None:
    REPORTS_DIR.mkdir(parents=True, exist_ok=True)
    intro_sections = build_intro_sections()

    REPORT_MD.write_text(render_markdown(intro_sections), encoding="utf-8")
    REPORT_TEX.write_text(render_tex(intro_sections), encoding="utf-8")

    print(f"Markdown report written to: {REPORT_MD}")
    print(f"LaTeX source written to: {REPORT_TEX}")


if __name__ == "__main__":
    main()
