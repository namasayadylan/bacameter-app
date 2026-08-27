<?php

class AnomaliController extends ControllerBase
{
    public function indexAction()
    {
        $stmt = $this->db->query(
            'SELECT id, kode, nama, tipe, status, pm
             FROM bacameter.cater_alasan
             ORDER BY kode ASC'
        );
        $list = $stmt->fetchAll(\PDO::FETCH_ASSOC);

        $this->view->setVar('anomaliList', $list);
    }

    public function createAction()
    {
        if ($this->request->isPost()) {
            $nama   = trim($this->request->getPost('nama', 'string'));
            $kode   = trim($this->request->getPost('kode', 'string'));
            $tipe   = trim($this->request->getPost('tipe', 'string'));
            $status = (int) $this->request->getPost('status', 'int', 1);
            $pm     = (int) $this->request->getPost('pm', 'int', 0);

            if ($nama === '' || $kode === '') {
                $this->view->setVar('errors', ['Nama dan Kode wajib diisi.']);
                $this->view->setVar('anomali', [
                    'kode'   => $kode,
                    'nama'   => $nama,
                    'tipe'   => $tipe,
                    'status' => $status,
                    'pm'     => $pm,
                ]);
            } else {
                $stmt = $this->db->prepare(
                    'INSERT INTO bacameter.cater_alasan (nama, kode, tipe, status, pm)
                     VALUES (:nama, :kode, :tipe, :status, :pm)'
                );
                $stmt->execute([
                    'nama'   => $nama,
                    'kode'   => $kode,
                    'tipe'   => $tipe,
                    'status' => $status,
                    'pm'     => $pm,
                ]);

                return $this->response->redirect('anomali');
            }
        } else {
            $this->view->setVar('anomali', null);
        }

        $this->view->setVar('mode', 'create');
        $this->view->setVar('pageTitle', 'Tambah Anomali');
        $this->view->setVar('formAction', $this->url->get('anomali/create'));
        $this->view->pick('anomali/form');
    }

    public function editAction(int $id)
    {
        $stmt = $this->db->prepare('SELECT * FROM bacameter.cater_alasan WHERE id = :id');
        $stmt->execute(['id' => $id]);
        $anomali = $stmt->fetch(\PDO::FETCH_ASSOC);

        if (!$anomali) {
            return $this->response->redirect('anomali');
        }

        if ($this->request->isPost()) {
            $nama   = trim($this->request->getPost('nama', 'string'));
            $kode   = trim($this->request->getPost('kode', 'string'));
            $tipe   = trim($this->request->getPost('tipe', 'string'));
            $status = (int) $this->request->getPost('status', 'int', 1);
            $pm     = (int) $this->request->getPost('pm', 'int', 0);

            if ($nama === '' || $kode === '') {
                $this->view->setVar('errors', ['Nama dan Kode wajib diisi.']);
                $anomali = [
                    'id'     => $id,
                    'kode'   => $kode,
                    'nama'   => $nama,
                    'tipe'   => $tipe,
                    'status' => $status,
                    'pm'     => $pm,
                ];
            } else {
                $stmt = $this->db->prepare(
                    'UPDATE bacameter.cater_alasan
                     SET nama = :nama, kode = :kode, tipe = :tipe, status = :status, pm = :pm
                     WHERE id = :id'
                );
                $stmt->execute([
                    'nama'   => $nama,
                    'kode'   => $kode,
                    'tipe'   => $tipe,
                    'status' => $status,
                    'pm'     => $pm,
                    'id'     => $id,
                ]);

                return $this->response->redirect('anomali');
            }
        }

        $this->view->setVar('mode', 'edit');
        $this->view->setVar('anomali', $anomali);
        $this->view->setVar('pageTitle', 'Edit Anomali');
        $this->view->setVar('formAction', $this->url->get('anomali/edit/' . $id));
        $this->view->pick('anomali/form');
    }

    public function deleteAction(int $id)
    {
        $stmt = $this->db->prepare('SELECT COUNT(*) AS jumlah FROM bacameter.datameter WHERE id_anomali = :id');
        $stmt->execute(['id' => $id]);
        $cek = $stmt->fetch(\PDO::FETCH_ASSOC);

        if ($cek['jumlah'] > 0) {
            return $this->response->redirect('anomali?error=used');
        }

        $stmt = $this->db->prepare('DELETE FROM bacameter.cater_alasan WHERE id = :id');
        $stmt->execute(['id' => $id]);

        return $this->response->redirect('anomali');
    }
}