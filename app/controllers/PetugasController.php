<?php

class PetugasController extends ControllerBase
{
    public function indexAction()
    {
        $stmt = $this->db->query(
            'SELECT id, username, nama, no_telp, petugas_os, zona_id
             FROM bacameter.petugas
             ORDER BY nama ASC'
        );
        $petugas = $stmt->fetchAll(\PDO::FETCH_ASSOC);

        $this->view->setVar('petugasList', $petugas);
    }

    public function createAction()
    {
        if ($this->request->isPost()) {
            $username   = trim($this->request->getPost('username', 'string'));
            $nama       = trim($this->request->getPost('nama', 'string'));
            $no_telp    = trim($this->request->getPost('no_telp', 'string'));
            $alamat     = trim($this->request->getPost('alamat', 'string'));
            $petugas_os = (int) $this->request->getPost('petugas_os', 'int', 0);
            $zona_id    = $this->request->getPost('zona_id', 'int', null);

            if ($username === '' || $nama === '') {
                $this->view->setVar('errors', ['Username dan Nama wajib diisi.']);
                $this->view->setVar('petugas', [
                    'username'   => $username,
                    'nama'       => $nama,
                    'no_telp'    => $no_telp,
                    'alamat'     => $alamat,
                    'petugas_os' => $petugas_os,
                    'zona_id'    => $zona_id,
                ]);
            } else {
                $stmt = $this->db->prepare(
                    'INSERT INTO bacameter.petugas (username, nama, no_telp, alamat, petugas_os, zona_id)
                     VALUES (:username, :nama, :no_telp, :alamat, :petugas_os, :zona_id)'
                );
                $stmt->execute([
                    'username'   => $username,
                    'nama'       => $nama,
                    'no_telp'    => $no_telp,
                    'alamat'     => $alamat,
                    'petugas_os' => $petugas_os,
                    'zona_id'    => $zona_id,
                ]);

                return $this->response->redirect('petugas');
            }
        } else {
            $this->view->setVar('petugas', null);
        }

        $this->view->setVar('mode', 'create');
        $this->view->setVar('pageTitle', 'Tambah Petugas');
        $this->view->setVar('formAction', $this->url->get('petugas/create'));
        $this->view->pick('petugas/form');
    }

    public function editAction(int $id)
    {
        $stmt = $this->db->prepare('SELECT * FROM bacameter.petugas WHERE id = :id');
        $stmt->execute(['id' => $id]);
        $petugas = $stmt->fetch(\PDO::FETCH_ASSOC);

        if (!$petugas) {
            return $this->response->redirect('petugas');
        }

        if ($this->request->isPost()) {
            $username   = trim($this->request->getPost('username', 'string'));
            $nama       = trim($this->request->getPost('nama', 'string'));
            $no_telp    = trim($this->request->getPost('no_telp', 'string'));
            $alamat     = trim($this->request->getPost('alamat', 'string'));
            $petugas_os = (int) $this->request->getPost('petugas_os', 'int', 0);
            $zona_id    = $this->request->getPost('zona_id', 'int', null);

            if ($username === '' || $nama === '') {
                $this->view->setVar('errors', ['Username dan Nama wajib diisi.']);
                $petugas = [
                    'id'         => $id,
                    'username'   => $username,
                    'nama'       => $nama,
                    'no_telp'    => $no_telp,
                    'alamat'     => $alamat,
                    'petugas_os' => $petugas_os,
                    'zona_id'    => $zona_id,
                ];
            } else {
                $stmt = $this->db->prepare(
                    'UPDATE bacameter.petugas
                     SET username = :username, nama = :nama, no_telp = :no_telp,
                         alamat = :alamat, petugas_os = :petugas_os, zona_id = :zona_id
                     WHERE id = :id'
                );
                $stmt->execute([
                    'username'   => $username,
                    'nama'       => $nama,
                    'no_telp'    => $no_telp,
                    'alamat'     => $alamat,
                    'petugas_os' => $petugas_os,
                    'zona_id'    => $zona_id,
                    'id'         => $id,
                ]);

                return $this->response->redirect('petugas');
            }
        }

        $this->view->setVar('mode', 'edit');
        $this->view->setVar('petugas', $petugas);
        $this->view->setVar('pageTitle', 'Edit Petugas');
        $this->view->setVar('formAction', $this->url->get('petugas/edit/' . $id));
        $this->view->pick('petugas/form');
    }

    public function deleteAction(int $id)
    {
        $stmt = $this->db->prepare('SELECT COUNT(*) AS jumlah FROM bacameter.datameter WHERE id_petugas = :id');
        $stmt->execute(['id' => $id]);
        $cek = $stmt->fetch(\PDO::FETCH_ASSOC);

        if ($cek['jumlah'] > 0) {
            return $this->response->redirect('petugas?error=used');
        }

        $stmt = $this->db->prepare('DELETE FROM bacameter.petugas WHERE id = :id');
        $stmt->execute(['id' => $id]);

        return $this->response->redirect('petugas');
    }
}