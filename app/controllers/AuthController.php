<?php

use Phalcon\Mvc\Controller;

/**
 * @property \PDO                              $db
 * @property \Phalcon\Http\Request              $request
 * @property \Phalcon\Http\Response              $response
 * @property \Phalcon\Session\Manager             $session
 * @property \Phalcon\Mvc\View                     $view
 */
class AuthController extends Controller
{
    public function loginAction()
    {
        if ($this->session->has('user_id')) {
            return $this->response->redirect('dashboard');
        }

        if ($this->request->isPost()) {
            $username = trim($this->request->getPost('username', 'string'));
            $password = $this->request->getPost('password', 'string');

            $stmt = $this->db->prepare(
                'SELECT id, username, password, nama, role
                 FROM dbo.[user]
                 WHERE username = :username AND is_active = 1'
            );
            $stmt->execute(['username' => $username]);
            $user = $stmt->fetch(\PDO::FETCH_ASSOC);

            if ($user && password_verify($password, $user['password'])) {
                $this->session->set('user_id', $user['id']);
                $this->session->set('username', $user['username']);
                $this->session->set('nama', $user['nama']);
                $this->session->set('role', $user['role']);

                return $this->response->redirect('dashboard');
            }

            $this->view->setVar('error', 'Username atau password salah.');
        }
        $this->view->setLayout(false);
    }
    public function logoutAction()
    {
        $this->session->destroy();

        return $this->response->redirect('login');
    }
}
