<?php

namespace Database\Seeders;

use App\Models\Disease;
use Illuminate\Database\Seeder;

class DiseaseSeeder extends Seeder
{
    public function run(): void
    {
        $diseases = [
            [
                'name' => 'Bercak Daun (Leaf Spot)',
                'scientific_name' => 'Cercospora capsici',
                'category' => 'Jamur',
                'image_url' => 'https://placehold.co/600x400/7CBF8A/FFFFFF?text=Bercak%20Daun',
                'description' => 'Penyakit bercak daun disebabkan jamur Cercospora capsici yang menyerang daun cabai. Muncul bercak cokelat keabu-abuan yang menyebar dari daun bagian bawah ke atas.',
                'symptoms' => 'Bercak lingkaran kecil cokelat tua dengan pusat kelabu, daun menguning lalu rontok.',
                'prevention_steps' => 'Pilih benih varietas tahan penyakit.||Atur jarak tanam agar sirkulasi udara lancar.||Hindari penyiraman dari atas daun dan jaga kebersihan lahan.',
            ],
            [
                'name' => 'Karat Daun (Rust)',
                'scientific_name' => 'Puccinia sorghi',
                'category' => 'Jamur',
                'image_url' => 'https://placehold.co/600x400/7CBF8A/FFFFFF?text=Karat%20Daun',
                'description' => 'Penyakit karat menyerang daun dengan bintik oranye keemasan seperti karat pada permukaan bawah daun, umum muncul pada musim lembap.',
                'symptoms' => 'Pustul berisi spora berwarna serbuk karat cokelat kemerahan di permukaan bawah daun.',
                'prevention_steps' => 'Gunakan varietas tahan karat.||Lakukan rotasi tanaman secara teratur.||Jaga sirkulasi udara dan hindari kelembapan berlebih.',
            ],
            [
                'name' => 'Layu Fusarium',
                'scientific_name' => 'Fusarium oxysporum',
                'category' => 'Jamur',
                'image_url' => 'https://placehold.co/600x400/7CBF8A/FFFFFF?text=Layu%20Fusarium',
                'description' => 'Penyakit layu yang disebabkan jamur tanah Fusarium oxysporum. Tanaman layu mendadak dan pembuluh batang berwarna cokelat.',
                'symptoms' => 'Daun bawah menguning lalu layu, batang tampak cekung, dan pangkal batang membusuk.',
                'prevention_steps' => 'Gunakan benih sehat dan varietas tahan layu.||Sterilkan media tanam dengan cara solarisasi.||Cabut dan musnahkan tanaman yang terinfeksi.',
            ],
            [
                'name' => 'Antraknosa (Patek)',
                'scientific_name' => 'Colletotrichum capsici',
                'category' => 'Jamur',
                'image_url' => 'https://placehold.co/600x400/7CBF8A/FFFFFF?text=Antraknosa',
                'description' => 'Penyakit patek menyerang buah dan daun cabai. Bercak cokelat dengan pusat lebih gelap seperti cincin dan buah membusuk berlendir.',
                'symptoms' => 'Bercak cekung cokelat pada buah dengan cincin spora oranye kemerahan, daun menguning.',
                'prevention_steps' => 'Gunakan fungisida nabati seperti ekstrak bawang putih.||Panen tepat waktu dan buang buah yang terserang.||Jaga kebersihan alat dan gulma sekitar lahan.',
            ],
            [
                'name' => 'Busuk Akar (Root Rot)',
                'scientific_name' => 'Pythium spp.',
                'category' => 'Bakteri',
                'image_url' => 'https://placehold.co/600x400/6B8FBF/FFFFFF?text=Busuk%20Akar',
                'description' => 'Busuk akar berkembang akibat media tanam terlalu basah dan serangan patogen tanah. Akar membusuk sehingga tanaman tidak dapat menyerap air.',
                'symptoms' => 'Daun menguning tiba-tiba, layu, dan batang bagian bawah lembek berair.',
                'prevention_steps' => 'Atur drainase pot atau media tanam.||Hentikan penyiraman sementara hingga media agak kering.||Gunakan agen hayati Trichoderma pada media tanam.',
            ],
            [
                'name' => 'Layu Bakteri',
                'scientific_name' => 'Ralstonia solanacearum',
                'category' => 'Bakteri',
                'image_url' => 'https://placehold.co/600x400/6B8FBF/FFFFFF?text=Layu%20Bakteri',
                'description' => 'Penyakit layu bakteri yang mematikan pada cabai. Bakteri menyumbat pembuluh sehingga tanaman layu permanen meski tanah lembap.',
                'symptoms' => 'Layu cepat tanpa daun menguning, batang dipotong mengeluarkan lendir putih, akar membusuk.',
                'prevention_steps' => 'Gunakan varietas tahan dan benih bebas penyakit.||Lakukan rotasi dengan tanaman bukan golongan terong-terongan.||Solarisasi tanah sebelum penanaman.',
            ],
            [
                'name' => 'Bercak Bakteri',
                'scientific_name' => 'Xanthomonas campestris',
                'category' => 'Bakteri',
                'image_url' => 'https://placehold.co/600x400/6B8FBF/FFFFFF?text=Bercak%20Bakteri',
                'description' => 'Bercak bakteri menyerang daun dan buah. Bercak cokelat basah dengan tepi kuning yang dapat menyebabkan daun gugur.',
                'symptoms' => 'Bercak kecil berair cokelat yang menyatu, daun keriting dan rontok.',
                'prevention_steps' => 'Gunakan benih bebas penyakit.||Hindari penyiraman dengan percikan air.||Pisahkan dan buang tanaman yang sakit.',
            ],
            [
                'name' => 'Virus Mosaik',
                'scientific_name' => 'Cucumber mosaic virus (CMV)',
                'category' => 'Virus',
                'image_url' => 'https://placehold.co/600x400/C9A86B/FFFFFF?text=Virus%20Mosaik',
                'description' => 'Virus mosaik disebarkan oleh kutu daun. Daun tampak belang-belang kuning-hijau, tanaman kerdil, dan buah kecil tidak normal.',
                'symptoms' => 'Daun belang mosaik, keriting, tepi menggulung, dan tanaman kerdil.',
                'prevention_steps' => 'Kendalikan kutu daun sebagai vektor penyebar virus.||Gunakan benih bebas virus.||Cabut tanaman terinfeksi segera.',
            ],
            [
                'name' => 'Daun Keriting Kuning (Virus Kuning)',
                'scientific_name' => 'Begomovirus (PepYLCV)',
                'category' => 'Virus',
                'image_url' => 'https://placehold.co/600x400/C9A86B/FFFFFF?text=Virus%20Kuning',
                'description' => 'Penyakit kuning keriting disebarkan kutu kebul. Daun muda menguning dan mengeriting sehingga pertumbuhan terhambat.',
                'symptoms' => 'Daun muda menguning dan mengeriting, tanaman kerdil, dan bunga rontok.',
                'prevention_steps' => 'Pasang perangkap kuning untuk menangkap kutu kebul.||Tutup lahan dengan mulsa plastik perak.||Gunakan varietas tahan virus kuning.',
            ],
            [
                'name' => 'Kutu Daun (Aphid)',
                'scientific_name' => 'Myzus persicae',
                'category' => 'Hama',
                'image_url' => 'https://placehold.co/600x400/C97B6B/FFFFFF?text=Kutu%20Daun',
                'description' => 'Serangan hama kutu daun mengisap cairan tanaman dan menjadi vektor virus. Koloni kutu tampak di pucuk dan daun muda.',
                'symptoms' => 'Daun keriting dan lengket (embun madu), pucuk pertumbuhan terhambat.',
                'prevention_steps' => 'Kendalikan dengan predator alami seperti kepik.||Semprot air sabun atau pestisida nabati.||Jaga kebersihan gulma di sekitar lahan.',
            ],
        ];

        foreach ($diseases as $disease) {
            Disease::firstOrCreate(['name' => $disease['name']], $disease);
        }
    }
}
