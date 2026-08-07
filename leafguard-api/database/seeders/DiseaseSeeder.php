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
                'image_url' => 'https://lh3.googleusercontent.com/aida-public/AB6AXuDImDcqK7-2TTfEsSRFVDFrIL3dQC65jCejg5cgzzThGqbPc0YSXIKHK65Bv3w6jaLbb4vCHoWMCu1it6APEayNlB3gCHUyBhrdSpETKR_zOBRDhX55O8SMMDhqzDi2RxH30VpHV7n4_4owIfcONwCDp3rtJrW96aeAUp9p6I5ANQylU_4936R6VO1pIDMY2tjqDjPk1tXDSjMhqIVSkGUc9eeDfuMpN75K-HkO-Tgj3NvEUWr_LbPUVQ',
                'description' => 'Bercak daun disebabkan oleh jamur Cercospora capsici. Penyakit ini membuat bercak cokelat keabu-abuan pada daun.',
                'symptoms' => 'Bercak lingkaran kecil berwarna cokelat tua dengan pusat kelabu.',
                'treatment_steps' => 'Kurangi kelembapan di sekitar area terdampak.||Buang bagian daun yang rusak parah agar tidak menular.||Berikan pupuk tambahan untuk memperkuat imun tanaman.',
            ],
            [
                'name' => 'Karat Daun (Rust)',
                'scientific_name' => 'Puccinia sorghi',
                'category' => 'Jamur',
                'image_url' => 'https://lh3.googleusercontent.com/aida-public/AB6AXuDImDcqK7-2TTfEsSRFVDFrIL3dQC65jCejg5cgzzThGqbPc0YSXIKHK65Bv3w6jaLbb4vCHoWMCu1it6APEayNlB3gCHUyBhrdSpETKR_zOBRDhX55O8SMMDhqzDi2RxH30VpHV7n4_4owIfcONwCDp3rtJrW96aeAUp9p6I5ANQylU_4936R6VO1pIDMY2tjqDjPk1tXDSjMhqIVSkGUc9eeDfuMpN75K-HkO-Tgj3NvEUWr_LbPUVQ',
                'description' => 'Karat daun dicirikan oleh bintik-bintik oranye keemasan seperti karat di permukaan bawah daun.',
                'symptoms' => 'Pustul berisi spora berwarna serbuk karat cokelat kemerahan.',
                'treatment_steps' => 'Semprotkan fungisida berbasis tembaga organik.||Jaga sirkulasi udara antar tanaman agar tidak terlalu rapat.||Hindari penyiraman langsung dari atas daun.',
            ],
            [
                'name' => 'Busuk Akar (Root Rot)',
                'scientific_name' => 'Pythium spp.',
                'category' => 'Bakteri',
                'image_url' => 'https://lh3.googleusercontent.com/aida-public/AB6AXuDImDcqK7-2TTfEsSRFVDFrIL3dQC65jCejg5cgzzThGqbPc0YSXIKHK65Bv3w6jaLbb4vCHoWMCu1it6APEayNlB3gCHUyBhrdSpETKR_zOBRDhX55O8SMMDhqzDi2RxH30VpHV7n4_4owIfcONwCDp3rtJrW96aeAUp9p6I5ANQylU_4936R6VO1pIDMY2tjqDjPk1tXDSjMhqIVSkGUc9eeDfuMpN75K-HkO-Tgj3NvEUWr_LbPUVQ',
                'description' => 'Busuk akar berkembang akibat media tanam terlalu basah dan serangan bakteri/patogen tanah.',
                'symptoms' => 'Daun menguning tiba-tiba, layu, dan batang bagian bawah lembek.',
                'treatment_steps' => 'Atur drainase pot atau media hidroponik.||Hentikan penyiraman sementara hingga media agak kering.||Gunakan agen hayati Trichoderma pada media tanam.',
            ],
        ];

        foreach ($diseases as $disease) {
            Disease::firstOrCreate(['name' => $disease['name']], $disease);
        }
    }
}
